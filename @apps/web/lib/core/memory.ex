defmodule Core.Memory do
  @moduledoc """
  Sandman-shaped memory banks: one bank per sanitized-cwd under `~/.claude/@memory`,
  plus Claude Code's read-only built-in banks. Memories use sandman frontmatter
  (`name`/`description`/`type`) and `<type>_<slug>.md` filenames. Whole conversations
  are dissolved via the local `claude` CLI — extracted, judge-verified, and committed
  autonomously; staging is only the judge-failure fallback and the mid-session inbox.
  """

  alias Core.Transcripts

  @types ~w(feedback project reference user)

  @default_steering """
  Dissolve the WHOLE conversation — never a fragment — so nothing is captured out of context.

  Keep only durable memories worth recalling in a future, unrelated session:
  - user — the user's role, preferences, working style
  - feedback — guidance the user gave (corrections AND validations)
  - project — ongoing work, goals, constraints not derivable from code or git
  - reference — pointers to external systems (dashboards, channels, tools, endpoints)

  Do NOT save (even if asked — instead capture what was *surprising*):
  - code patterns, conventions, architecture, file paths — derivable from the project
  - git history; debugging fix recipes — the fix lives in the code/commit
  - anything already in CLAUDE.md; ephemeral task detail

  For feedback/project, structure the body as the rule/memory, then a **Why:** line, then a **How to apply:** line. Convert relative dates to absolute.\
  """

  @types_doc "Types — user (role/preferences), feedback (guidance the user gave — corrections AND validations), project (ongoing work/goals/constraints not derivable from code/git), reference (pointers to external systems)."
  @shape ~s(Each item: {"name":"human-readable title","description":"one-line recall summary, specific","type":"user|feedback|project|reference","body":"the memory; for feedback/project add **Why:** and **How to apply:** lines"})

  # ── paths ─────────────────────────────────────────────────
  def memory_root, do: Path.join(System.user_home!(), ".claude/@memory")
  defp sandman_root, do: Path.join(System.user_home!(), ".claude/skills/sandman/memories")
  defp staging_path, do: Path.join(memory_root(), ".staging.json")
  defp steering_path, do: Path.join(memory_root(), "_steering.md")

  defp sanitize(cwd), do: String.replace(cwd, ~r/[^a-zA-Z0-9]/, "-")

  defp slug(name) do
    base =
      name
      |> to_string()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "_")
      |> String.trim("_")
      |> String.slice(0, 60)

    # A name that is entirely punctuation/whitespace collapses to "" — never let two
    # such memories share `<type>_.md`; fall back to a stable digest of the raw name.
    if base == "", do: "x" <> digest(name), else: base
  end

  defp digest(s),
    do: :crypto.hash(:sha, to_string(s)) |> Base.encode16(case: :lower) |> binary_part(0, 8)

  defp file_name(f), do: "#{f.type}_#{slug(f.name)}.md"

  # Two distinct names can still slug to the same file (`"Deploy process"` /
  # `"Deploy Process!"`). Committing the second would overwrite the first, so if the
  # target exists and belongs to a *different* memory (not one this commit replaces),
  # disambiguate with a numeric suffix rather than clobber.
  defp commit_file_name(dir, f) do
    base = file_name(f)
    owned = [base | f[:replaces] || []]

    if collision?(Path.join(dir, base), f.name, owned),
      do: free_name(dir, f.type, slug(f.name), 2),
      else: base
  end

  defp collision?(path, name, owned) do
    File.exists?(path) and Path.basename(path) not in owned and
      case File.read(path) do
        {:ok, raw} -> parse_memory(raw, path, nil).name != name
        _ -> false
      end
  end

  defp free_name(dir, type, slug, n) do
    candidate = "#{type}_#{slug}_#{n}.md"

    if File.exists?(Path.join(dir, candidate)),
      do: free_name(dir, type, slug, n + 1),
      else: candidate
  end

  defp abbrev(cwd) do
    home = System.user_home!()
    if String.starts_with?(cwd, home), do: "~" <> String.replace_prefix(cwd, home, ""), else: cwd
  end

  # ── frontmatter ───────────────────────────────────────────
  defp parse_memory(raw, file, bank) do
    {meta, body0} =
      case Regex.run(~r/\A---\r?\n(.*?)\r?\n---\r?\n?(.*)\z/s, raw) do
        [_, fm, body] -> {parse_fm(fm), String.trim(body)}
        _ -> {%{}, String.trim(raw)}
      end

    prefix = file |> Path.basename() |> String.split("_") |> hd()

    type =
      cond do
        meta["type"] in @types -> meta["type"]
        prefix in @types -> prefix
        true -> "reference"
      end

    {name, body} =
      case meta["name"] do
        nil ->
          case Regex.run(~r/^#\s+(.+)$/m, body0) do
            [_, h1] ->
              {String.trim(h1), body0 |> String.replace(~r/^#\s+.+\n*/, "") |> String.trim()}

            _ ->
              {Path.basename(file, ".md"), body0}
          end

        n ->
          {n, body0}
      end

    %{
      bank: bank,
      body: body,
      description: meta["description"] || "",
      file: Path.basename(file),
      name: name,
      source: meta["source"],
      type: type
    }
  end

  defp parse_fm(fm) do
    fm
    # split on \r?\n so CRLF frontmatter doesn't leave a trailing \r on every value
    # (which would make e.g. `type: reference\r` fail the `in @types` check).
    |> String.split(~r/\r?\n/)
    |> Enum.reduce(%{}, fn line, acc ->
      case Regex.run(~r/^\s*([\w-]+):\s*(.+)$/, line) do
        [_, k, v] -> Map.put(acc, k, v |> String.trim() |> strip_quotes())
        _ -> acc
      end
    end)
  end

  defp strip_quotes(s), do: String.replace(s, ~r/^["']|["']$/, "")

  defp serialize_memory(f) do
    fm = ["---", "name: #{f.name}", "description: #{f.description}", "type: #{f.type}"]
    fm = if f[:source], do: fm ++ ["source: #{f.source}"], else: fm
    Enum.join(fm ++ ["---", "", String.trim(f.body), ""], "\n")
  end

  # ── seed canonical store from the sandman corpus (artwork) ──
  defp seed_from_sandman do
    case File.ls(sandman_root()) do
      {:ok, banks} -> Enum.each(banks, &seed_bank/1)
      _ -> :ok
    end
  end

  defp seed_bank(bank) do
    dst = Path.join(memory_root(), bank)

    with false <- File.exists?(Path.join(dst, ".seeded")),
         {:ok, files} <- File.ls(Path.join(sandman_root(), bank)),
         true <- Enum.any?(files, &String.ends_with?(&1, ".md")) do
      File.mkdir_p!(dst)

      for f <- files, String.ends_with?(f, ".md"), not File.exists?(Path.join(dst, f)) do
        File.cp!(Path.join([sandman_root(), bank, f]), Path.join(dst, f))
      end

      File.write!(Path.join(dst, ".seeded"), "")
    else
      _ -> :ok
    end
  end

  # ── banks ─────────────────────────────────────────────────
  defp read_dir(dir, id, label, kind) do
    bank = %{memories: [], id: id, index: "", kind: kind, label: label, readonly: kind == :auto}

    case File.ls(dir) do
      {:ok, entries} ->
        entries
        |> Enum.sort()
        |> Enum.reduce(bank, fn name, b ->
          cond do
            not String.ends_with?(name, ".md") ->
              b

            name == "MEMORY.md" ->
              %{b | index: File.read!(Path.join(dir, name))}

            String.starts_with?(name, "_") ->
              b

            true ->
              %{b | memories: b.memories ++ [parse_memory(File.read!(Path.join(dir, name)), name, id)]}
          end
        end)

      _ ->
        bank
    end
  end

  defp read_bank(id, label), do: read_dir(Path.join(memory_root(), id), id, label, :managed)

  # Recover a project's real cwd from a session file (auto-memory dir names are lossy).
  defp project_cwd(project) do
    # Same `--` → `/.` heuristic as label_from_id — a hidden dir like ~/.grove
    # sanitizes to `--grove`, and a bare `-`→`/` pass would render it `//grove`.
    fallback =
      "/" <>
        (project
         |> String.replace_prefix("-", "")
         |> String.replace("--", "-.")
         |> String.replace("-", "/"))

    Path.join(Transcripts.projects_dir(), "#{project}/*.jsonl")
    |> Path.wildcard()
    |> Enum.find_value(fallback, fn file ->
      file
      |> File.stream!()
      |> Enum.find_value(fn line ->
        case Jason.decode(line) do
          {:ok, %{"cwd" => cwd}} when is_binary(cwd) -> cwd
          _ -> nil
        end
      end)
    end)
  end

  defp read_auto_banks do
    Transcripts.projects_dir()
    |> Path.join("*/memory")
    |> Path.wildcard()
    |> Enum.map(fn dir ->
      project = dir |> Path.relative_to(Transcripts.projects_dir()) |> Path.split() |> hd()
      read_dir(dir, "auto:" <> project, abbrev(project_cwd(project)), :auto)
    end)
    |> Enum.filter(&(&1.memories != [] or &1.index != ""))
  end

  def list_banks do
    seed_from_sandman()

    cwd_by_bank =
      Enum.reduce(Transcripts.list_sessions(), %{}, fn s, acc ->
        san = sanitize(s.cwd)
        acc |> Map.put(san, s.cwd) |> Map.put(String.downcase(san), s.cwd)
      end)

    san_home = sanitize(System.user_home!())
    staged = read_staging()

    dir_banks =
      case File.ls(memory_root()) do
        {:ok, dirs} -> dirs
        _ -> []
      end

    # Banks that exist only in the staging queue (never committed → no dir yet) must
    # still surface, else dissolved candidates are invisible until first commit.
    staged_banks = staged |> Enum.map(& &1.bank) |> Enum.reject(&is_nil/1)

    managed =
      (dir_banks ++ staged_banks)
      |> Enum.uniq()
      |> Enum.reject(&(String.starts_with?(&1, ".") or String.starts_with?(&1, "_")))
      |> Enum.sort()
      |> Enum.map(fn id ->
        real = cwd_by_bank[id] || cwd_by_bank[String.downcase(id)]
        label = if real, do: abbrev(real), else: label_from_id(id, san_home)
        bank = read_bank(id, label)
        %{bank | memories: bank.memories ++ Enum.filter(staged, &(&1.bank == id))}
      end)
      |> Enum.filter(&(&1.memories != [] or &1.index != ""))

    managed ++ read_auto_banks()
  end

  defp label_from_id(id, san_home) do
    id
    |> String.replace_prefix(san_home, "~")
    |> String.replace("--", "/.")
    |> String.replace("-", "/")
  end

  # ── staging (review queue) ────────────────────────────────
  def read_staging do
    with {:ok, txt} <- File.read(staging_path()),
         {:ok, list} when is_list(list) <- Jason.decode(txt) do
      list
      |> Enum.map(fn m ->
        %{
          bank: m["bank"],
          body: m["body"],
          description: m["description"] || "",
          file: "",
          name: m["name"],
          replaces: m["replaces"],
          source: m["source"],
          staged: true,
          type: m["type"] || "reference"
        }
      end)
      # A candidate with no name/bank can't be committed (slug/path derive from name) —
      # drop malformed entries rather than let one crash commit_memory later.
      |> Enum.filter(&(is_binary(&1.name) and &1.name != "" and Core.Store.component?(&1.bank)))
    else
      _ -> []
    end
  end

  defp write_staging(memories) do
    File.mkdir_p!(memory_root())

    data =
      Enum.map(memories, fn f ->
        %{
          bank: f.bank,
          body: f.body,
          description: f.description,
          name: f.name,
          replaces: f[:replaces],
          source: f[:source],
          type: f.type
        }
      end)

    Core.Store.write!(staging_path(), Jason.encode!(data, pretty: true))
  end

  # ── steering ──────────────────────────────────────────────
  def get_steering do
    case File.read(steering_path()) do
      {:ok, txt} -> (String.trim(txt) == "" && @default_steering) || String.trim(txt)
      _ -> @default_steering
    end
  end

  def set_steering(text) do
    File.mkdir_p!(memory_root())
    File.write!(steering_path(), String.trim(text) <> "\n")
  end

  # ── index + mutations ─────────────────────────────────────
  defp regen_index(bank) do
    %{memories: memories} = read_bank(bank, "")

    lines =
      Enum.map(memories, fn f ->
        "- [#{f.name}](#{f.file}) — #{f.description |> String.replace(~r/\s+/, " ") |> String.slice(0, 150)}"
      end)

    head =
      "---\nname: MEMORY index\ndescription: One-line map of all durable memories in this knowledge bank\ntype: reference\n---\n\n"

    File.write!(
      Path.join([memory_root(), bank, "MEMORY.md"]),
      head <> Enum.join(lines, "\n") <> "\n"
    )
  end

  # Managed = a real cwd-bank the user steers; `auto:` banks are Claude Code's own,
  # read-only. `writable?` also rejects a bank id that isn't a safe path segment, so a
  # tampered request (`bank: "../.."`) can't escape the memory root.
  defp writable?(bank), do: not match?("auto:" <> _, bank) and Core.Store.component?(bank)

  def commit_memory(f) do
    if writable?(f.bank) do
      dir = Path.join(memory_root(), f.bank)
      File.mkdir_p!(dir)
      # only remove replaced files that are plain components within this bank
      for r <- f[:replaces] || [], Core.Store.component?(r), do: File.rm(Path.join(dir, r))
      File.write!(Path.join(dir, commit_file_name(dir, f)), serialize_memory(f))
      read_staging() |> Enum.reject(&(&1.bank == f.bank and &1.name == f.name)) |> write_staging()
      regen_index(f.bank)
      :ok
    else
      {:error, :not_writable}
    end
  end

  def reject_staged(bank, name) do
    read_staging() |> Enum.reject(&(&1.bank == bank and &1.name == name)) |> write_staging()
  end

  def delete_memory(bank, file) do
    if writable?(bank) and Core.Store.component?(file) do
      File.rm(Path.join([memory_root(), bank, file]))
      regen_index(bank)
    else
      {:error, :not_writable}
    end
  end

  # ── distillation via local claude CLI ─────────────────────
  defp one_line(input) when is_map(input) do
    v =
      input["command"] || input["file_path"] || input["pattern"] || input["query"] ||
        input["description"]

    v = if is_binary(v), do: v, else: Jason.encode!(input)
    v |> String.replace(~r/\s+/, " ") |> String.slice(0, 100)
  end

  defp one_line(_), do: ""

  defp flatten(session) do
    text =
      session.messages
      |> Enum.reject(& &1.is_meta)
      |> Enum.map(&flatten_message/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n\n")

    if String.length(text) > 60_000,
      do: String.slice(text, 0, 60_000) <> "\n…[truncated]",
      else: text
  end

  defp flatten_message(m) do
    segs =
      Enum.flat_map(m.blocks, fn
        %{kind: "text", text: t} ->
          [t]

        %{kind: "tool_use", name: n, input: i} ->
          ["[tool #{n}: #{one_line(i)}]"]

        %{kind: "tool_result", is_error: e, content: c} ->
          [
            "[result#{if e, do: " ERROR", else: ""}: #{c |> String.replace(~r/\s+/, " ") |> String.slice(0, 220)}]"
          ]

        _ ->
          []
      end)

    if segs == [], do: nil, else: "### #{m.role}\n" <> Enum.join(segs, "\n")
  end

  defp run_claude(prompt) do
    tmp = Path.join(System.tmp_dir!(), "claude_distill_#{System.unique_integer([:positive])}.txt")
    File.write!(tmp, prompt)
    claude = System.find_executable("claude") || "claude"
    {out, _} = System.cmd("sh", ["-c", ~s('#{claude}' -p --output-format json < '#{tmp}')])
    File.rm(tmp)

    case Jason.decode(out) do
      {:ok, %{"result" => r}} -> r
      _ -> out
    end
  end

  defp extract_json(text, open) do
    close = if open == "[", do: "]", else: "}"

    with s when not is_nil(s) <- index_of(text, open),
         e when not is_nil(e) <- last_index_of(text, close),
         true <- e > s,
         {:ok, val} <- Jason.decode(binary_part(text, s, e - s + 1)) do
      val
    else
      _ -> nil
    end
  end

  defp index_of(text, ch) do
    case :binary.match(text, ch) do
      {i, _} -> i
      :nomatch -> nil
    end
  end

  defp last_index_of(text, ch) do
    case :binary.matches(text, ch) do
      [] -> nil
      list -> list |> List.last() |> elem(0)
    end
  end

  defp sanitize_memory(raw, bank, source, replaces) when is_map(raw) do
    name = raw["name"]
    body = raw["body"]

    if is_binary(name) and name != "" and is_binary(body) and body != "" do
      %{
        bank: bank,
        body: body,
        description: (raw["description"] || "") |> to_string() |> String.replace(~r/\s+/, " "),
        file: "",
        name: name |> String.replace(~r/\s+/, " ") |> String.trim() |> String.slice(0, 90),
        replaces: replaces,
        source: source,
        staged: true,
        type: (raw["type"] in @types && raw["type"]) || "reference"
      }
    end
  end

  defp sanitize_memory(_, _, _, _), do: nil

  # Second `claude` pass: judge each candidate for autonomous commit (no human review
  # downstream). Returns the survivors with `replaces` resolved against the bank; an
  # unparseable judge response returns nil so the caller can fall back to staging
  # rather than silently losing the candidates.
  defp judge(candidates, bank) do
    existing =
      read_bank(bank, "").memories
      |> Enum.map_join("\n", &"- #{&1.file}: #{&1.name} — #{&1.description}")

    prompt = """
    You are a memory-quality judge for AUTONOMOUS commits — no human reviews these. Judge each CANDIDATE on all bars: durable (useful in a future, unrelated session) · non-derivable (not obvious from the project's code/git) · one idea per memory · description specific enough to trigger recall. Dedup: a candidate covered by an EXISTING memory is a drop; a candidate that updates or subsumes existing memory(s) commits with those filenames in "replaces". When in doubt, drop — a missed memory costs less than committed noise.

    EXISTING MEMORIES in this bank:
    #{(existing == "" && "(none)") || existing}

    CANDIDATES:
    #{Jason.encode!(Enum.map(candidates, &Map.take(&1, [:body, :description, :name, :type])))}

    Return ONLY a JSON array, one entry per candidate, no prose, no code fences: [{"name":"<candidate name>","verdict":"commit|drop","replaces":["<existing filename to supersede>"]}]
    """

    case extract_json(run_claude(prompt), "[") do
      verdicts when is_list(verdicts) and verdicts != [] ->
        by_name = Map.new(verdicts, &{&1["name"], &1})

        Enum.flat_map(candidates, fn c ->
          case by_name[c.name] do
            %{"verdict" => "commit"} = v ->
              [%{c | replaces: Enum.filter(v["replaces"] || [], &Core.Store.component?/1)}]

            _ ->
              []
          end
        end)

      _ ->
        nil
    end
  end

  @doc """
  Dissolve a WHOLE conversation into durable memories for its cwd-bank — verified by a
  judge pass, then committed automatically (no review queue). Staging is only the
  fallback when the judge call itself fails.
  """
  def distill_session(project, id) do
    case Transcripts.get_session(project, id) do
      nil ->
        raise "session not found"

      session ->
        bank = sanitize(session.cwd)

        prompt = """
        You distill an ENTIRE Claude Code conversation into durable memories. The whole conversation is provided so nothing is captured out of context.

        STEERING (the user's curation guidance — follow it):
        #{get_steering()}

        #{@types_doc}

        Extract 0 to 8 memories. Return ONLY a JSON array, no prose, no code fences. #{@shape}

        CONVERSATION (titled "#{session.title}", cwd #{session.cwd}):
        #{flatten(session)}
        """

        candidates =
          (extract_json(run_claude(prompt), "[") || [])
          |> Enum.map(&sanitize_memory(&1, bank, id, nil))
          |> Enum.reject(&is_nil/1)

        case {candidates, candidates != [] && judge(candidates, bank)} do
          {[], _} ->
            %{bank: bank, memories: [], dropped: 0, staged: 0}

          {_, nil} ->
            # judge unavailable — stage rather than lose the extraction
            staged =
              read_staging()
              |> Enum.reject(fn s ->
                s.bank == bank and Enum.any?(candidates, &(&1.name == s.name))
              end)

            write_staging(staged ++ candidates)
            %{bank: bank, memories: [], dropped: 0, staged: length(candidates)}

          {_, committed} ->
            Enum.each(committed, &commit_memory/1)

            %{
              bank: bank,
              memories: committed,
              dropped: length(candidates) - length(committed),
              staged: 0
            }
        end
    end
  end

  @doc "Merge several committed memories in one bank into a single replacing candidate."
  def merge_memories(bank, files) do
    sources =
      if writable?(bank) do
        files
        |> Enum.filter(&Core.Store.component?/1)
        |> Enum.map(fn file ->
          case File.read(Path.join([memory_root(), bank, file])) do
            {:ok, raw} -> parse_memory(raw, file, bank)
            _ -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)
      else
        []
      end

    if length(sources) < 2 do
      {:error, :need_two}
    else
      prompt = """
      Merge these overlapping memories into ONE consolidated memory. Preserve every [[wikilink]] and keep the most specific detail. Return ONLY a JSON object, no prose. #{@shape}

      MEMORIES:
      #{Enum.map_join(sources, "\n---\n", &serialize_memory/1)}
      """

      case sanitize_memory(extract_json(run_claude(prompt), "{"), bank, nil, files) do
        nil ->
          nil

        merged ->
          staged = read_staging() |> Enum.reject(&(&1.bank == bank and &1.name == merged.name))
          write_staging(staged ++ [merged])
          merged
      end
    end
  end
end
