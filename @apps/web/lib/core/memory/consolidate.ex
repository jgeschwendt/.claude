defmodule Core.Memory.Consolidate do
  @moduledoc """
  The sleep-time pass: between sessions, spend compute making each bank *smaller and
  sharper* rather than waiting for recall to fail. (Offline consolidation is the
  best-evidenced quality axis for a personal memory bank — see
  `~/.claude/@research/claude-memory-system/report.md`.)

  A bank is due when it has gained `@growth_trigger`+ memories since its last pass and
  the last pass is `@min_interval_hours`+ old (state in the bank's
  `_consolidation.json`). One `claude` call reads the whole bank (they're small by
  design) and proposes a capped set of ops; each op is applied through
  `Core.Memory.commit_memory`/`delete_memory`, so consolidation inherits every
  safety property of a normal commit — archive-over-delete, collision suffixes,
  `created` lineage across merges, index regeneration. The op set is deliberately
  tiny (merge · rewrite · archive) and the instruction is net-non-increasing: a
  consolidation may never grow the bank.
  """

  alias Core.Memory

  @growth_trigger 5
  @min_interval_hours 20
  @max_ops 6

  @ops_schema %{
    "type" => "object",
    "properties" => %{
      "ops" => %{
        "type" => "array",
        "items" => %{
          "type" => "object",
          "properties" => %{
            "op" => %{"enum" => ["archive", "merge", "rewrite"]},
            "files" => %{"type" => "array", "items" => %{"type" => "string"}},
            "reason" => %{"type" => "string"},
            "memory" => %{
              "type" => "object",
              "properties" => %{
                "body" => %{"type" => "string"},
                "description" => %{"type" => "string"},
                "name" => %{"type" => "string"},
                "type" => %{"enum" => ~w(feedback project reference user)}
              },
              "required" => ~w(body description name type)
            }
          },
          "required" => ~w(op files reason)
        }
      }
    },
    "required" => ["ops"]
  }

  @doc "Run consolidation on every due managed bank. Returns a list of per-bank reports."
  def run_due do
    case File.ls(Memory.memory_root()) do
      {:ok, dirs} ->
        dirs
        |> Enum.reject(&(String.starts_with?(&1, ".") or String.starts_with?(&1, "_")))
        |> Enum.filter(&File.dir?(Path.join(Memory.memory_root(), &1)))
        |> Enum.filter(&(baseline!(&1) and due?(&1)))
        |> Enum.map(&consolidate/1)

      _ ->
        []
    end
  end

  # A bank seen for the first time gets a baseline instead of a pass: growth is
  # measured from here on, so switching the sweep on never mass-consolidates a
  # hand-curated backlog in one unsupervised run.
  defp baseline!(bank) do
    if read_state(bank) == %{} do
      write_state(bank, [])
      false
    else
      true
    end
  end

  defp state_path(bank), do: Path.join([Memory.memory_root(), bank, "_consolidation.json"])

  defp read_state(bank) do
    with {:ok, txt} <- File.read(state_path(bank)),
         {:ok, map} when is_map(map) <- Jason.decode(txt) do
      map
    else
      _ -> %{}
    end
  end

  defp due?(bank) do
    memories = Memory.bank_memories(bank)
    state = read_state(bank)

    grown = length(memories) - (state["count"] || 0) >= @growth_trigger

    rested =
      case DateTime.from_iso8601(state["at"] || "") do
        {:ok, dt, _} -> DateTime.diff(DateTime.utc_now(), dt, :hour) >= @min_interval_hours
        _ -> true
      end

    memories != [] and grown and rested
  end

  @doc "Consolidate one bank now (also used by the dashboard's manual trigger)."
  def consolidate(bank) do
    memories = Memory.bank_memories(bank)

    prompt = """
    You are the CONSOLIDATION pass for a personal memory bank — an autonomous rewrite with no human review. Propose at most #{@max_ops} ops that make the bank SMALLER and SHARPER; when nothing clearly qualifies, return zero ops. Never invent facts — every output memory must be derivable from the inputs.

    Ops:
    - merge: 2+ overlapping memories → files + one consolidated "memory" (keep the most specific detail, preserve every [[wikilink]])
    - rewrite: 1 memory whose name/description is too vague to trigger recall → files=[that file] + sharpened "memory" (body may only be clarified, never extended)
    - archive: 1 memory that is stale, superseded, or ephemeral-in-hindsight → files=[that file], no "memory"

    BANK "#{bank}" (#{length(memories)} memories):
    #{Enum.map_join(memories, "\n===\n", &"FILE #{&1.file}\nname: #{&1.name}\ndescription: #{&1.description}\ntype: #{&1.type}\ncreated: #{&1.created}\n#{&1.body}")}
    """

    case Core.Claude.run(prompt, schema: @ops_schema) do
      {:ok, %{output: %{"ops" => ops}, cost: cost}} ->
        applied =
          ops
          |> Enum.take(@max_ops)
          |> Enum.filter(&valid_op?(&1, memories))
          |> Enum.map(&apply_op(&1, bank))

        write_state(bank, applied)
        %{bank: bank, ops: applied, cost: cost, error: nil}

      {:error, reason} ->
        %{bank: bank, ops: [], cost: 0, error: reason}
    end
  end

  # An op may only touch files that really are committed memories of this bank, and
  # merge/rewrite must carry a replacement memory.
  defp valid_op?(op, memories) do
    files = op["files"] || []
    known = MapSet.new(memories, & &1.file)

    files != [] and Enum.all?(files, &MapSet.member?(known, &1)) and
      case op["op"] do
        "archive" -> true
        "merge" -> length(files) >= 2 and is_map(op["memory"])
        "rewrite" -> length(files) == 1 and is_map(op["memory"])
        _ -> false
      end
  end

  defp apply_op(%{"op" => "archive"} = op, bank) do
    for f <- op["files"], do: Memory.delete_memory(bank, f)
    summarize(op)
  end

  defp apply_op(%{"op" => _, "memory" => m} = op, bank) do
    Memory.commit_memory(%{
      bank: bank,
      body: m["body"],
      description: m["description"],
      name: m["name"],
      replaces: op["files"],
      source: nil,
      type: m["type"]
    })

    summarize(op)
  end

  defp summarize(op),
    do: %{op: op["op"], files: op["files"], reason: op["reason"], name: op["memory"]["name"]}

  defp write_state(bank, applied) do
    state = %{
      "at" => DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      "count" => length(Memory.bank_memories(bank)),
      "last_ops" => length(applied)
    }

    Core.Store.write!(state_path(bank), Jason.encode!(state, pretty: true))
  end
end
