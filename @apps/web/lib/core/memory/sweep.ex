defmodule Core.Memory.Sweep do
  @moduledoc """
  The automatic half of the memory lifecycle: find conversations that ended without a
  manual `/dissolve`, dissolve them through the same extract → judge → commit pipeline,
  and consume their transcripts (gzip-archive to the diary, then remove — recoverable,
  not resumable). Driven unattended by the "Memory sweep" routine (launchd), so every
  decision here must be idempotent and fail-safe:

    * **Quiescence, not hooks** — a session qualifies only after `@idle_hours` without
      a new message. Session-end hooks were deliberately rejected (they're disabled in
      some sessions, and an end event can't shorten the idle wait anyway — a
      just-ended session may still be resumed tomorrow).
    * **Ledger** (`@memory/.sweep.jsonl`, append-only) — one line per handled session;
      makes re-runs no-ops and gives the dashboard provenance. A `dissolved`/`staged`
      outcome is permanent (the transcript is consumed); `trivial` re-arms when the
      session gains new messages; `error` retries next sweep.
    * **Trivial guard** — sessions with fewer than `@min_messages` renderable messages
      are ledgered without spending a claude call; their transcripts are left alone.
    * **Caps** — at most `max` (default 3) dissolves per run, so a backlog or a
      runaway scheduler can't burn unbounded tokens.
    * **Respect the wrapper** — a live transcript pre-marked archive-on-exit
      (`@log/.archive-on-exit/<sid>`) belongs to the session-end machinery; skipped.

  Mid-session inbox entries (`.staging.json`) and due consolidation passes ride the
  same sweep, so one scheduled entry point drives the whole autonomous lifecycle.
  """

  alias Core.{Memory, Transcripts}

  @idle_hours 48
  @max_default 3
  @min_messages 4

  def ledger_path, do: Path.join(Memory.memory_root(), ".sweep.jsonl")

  defp archive_on_exit_dir, do: Path.join(System.user_home!(), ".claude/@log/.archive-on-exit")

  @doc """
  One sweep: drain the inbox, dissolve up to `max` due sessions, run due
  consolidations. Returns a report map (also printed by the mix task).
  """
  def run(opts \\ []) do
    max = opts[:max] || @max_default
    now = DateTime.utc_now()
    ledger = read_ledger()

    {due, trivial} =
      Transcripts.list_sessions()
      |> Enum.filter(&sweepable?(&1, ledger, now))
      |> Enum.split_with(&(&1.message_count >= @min_messages))

    Enum.each(
      trivial,
      &record(%{outcome: "trivial", project: &1.project, id: &1.id, updated_at: &1.updated_at})
    )

    results = due |> Enum.take(max) |> Enum.map(&dissolve/1)

    %{
      considered: length(due) + length(trivial),
      consolidated: Core.Memory.Consolidate.run_due(),
      deferred: max(length(due) - max, 0),
      inbox: Memory.drain_inbox(),
      results: results,
      trivial: length(trivial)
    }
  end

  defp sweepable?(session, ledger, now) do
    quiescent?(session, now) and not marked_archive_on_exit?(session.id) and
      case ledger[{session.project, session.id}] do
        nil -> true
        # a "trivial" verdict re-arms when the session has since gained messages
        %{"outcome" => "trivial"} = e -> e["updated_at"] != session.updated_at
        %{"outcome" => "error"} -> true
        _permanent -> false
      end
  end

  defp quiescent?(%{updated_at: ts}, now) when is_binary(ts) and ts != "" do
    case DateTime.from_iso8601(ts) do
      {:ok, dt, _} -> DateTime.diff(now, dt, :hour) >= @idle_hours
      _ -> false
    end
  end

  defp quiescent?(_, _), do: false

  defp marked_archive_on_exit?(id), do: File.exists?(Path.join(archive_on_exit_dir(), id))

  # Consume the transcript on any successful extraction — including `staged` (the
  # candidates are safely in the inbox awaiting the next judge) and a clean zero
  # (nothing durable in the conversation). Only an extraction *error* leaves the
  # transcript for retry.
  defp dissolve(session) do
    result = Memory.distill_session(session.project, session.id)

    outcome =
      cond do
        result.error -> "error"
        result.staged > 0 -> "staged"
        true -> "dissolved"
      end

    if outcome != "error", do: Transcripts.delete_session(session.project, session.id)

    record(%{
      outcome: outcome,
      project: session.project,
      id: session.id,
      title: session.title,
      bank: result.bank,
      memories: Enum.map(result.memories, & &1.name),
      dropped: result.dropped,
      staged: result.staged,
      error: result.error && inspect(result.error),
      updated_at: session.updated_at
    })

    %{id: session.id, title: session.title, outcome: outcome, memories: length(result.memories)}
  end

  # ── ledger ────────────────────────────────────────────────
  # Append-only JSONL; the newest line per {project, id} wins on read.
  defp record(entry) do
    File.mkdir_p!(Memory.memory_root())

    line =
      entry
      |> Map.put(:at, DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601())
      |> Jason.encode!()

    File.write!(ledger_path(), line <> "\n", [:append])
  end

  defp read_ledger do
    case File.read(ledger_path()) do
      {:ok, txt} ->
        txt
        |> String.split("\n", trim: true)
        |> Enum.reduce(%{}, fn line, acc ->
          case Jason.decode(line) do
            {:ok, %{"project" => p, "id" => id} = e} -> Map.put(acc, {p, id}, e)
            _ -> acc
          end
        end)

      _ ->
        %{}
    end
  end

  @doc "Newest-first ledger entries for the dashboard, capped at `n`."
  def recent(n \\ 30) do
    case File.read(ledger_path()) do
      {:ok, txt} ->
        txt
        |> String.split("\n", trim: true)
        |> Enum.reverse()
        |> Enum.take(n)
        |> Enum.flat_map(fn line ->
          case Jason.decode(line) do
            {:ok, e} -> [e]
            _ -> []
          end
        end)

      _ ->
        []
    end
  end
end
