defmodule Core.UserLog do
  @moduledoc """
  A day-by-day diary — "what I did" — for looking back across the year. Plain files
  under `~/.claude/@log`, one page per day, mirroring `Core.Memory`'s habit of
  keeping markdown under `~/.claude` and shelling out to `claude` for the hard part.

  Each day holds up to two files so the auto and manual halves never clobber each other:

    * `YYYY-MM-DD.dream.md`  — the **daily dream**: a compact summary of the day's
      conversations, written by `claude` (on demand here, or nightly via a Routine).
    * `YYYY-MM-DD.notes.md`  — your own notes for the day, edited in the dashboard.

  The dream is the diary's sibling to `Memory`'s dissolve: dissolve distills one
  conversation into durable memories; the dream distills a whole *day* into one page. When
  a session is killed (`/delete` / `/dissolve`), its raw transcript is "compact-deleted" —
  gzip-archived under `archive/YYYY-MM-DD/` rather than removed — so the dream still has
  the day's conversations to draw on and nothing is lost.
  """

  alias Core.Transcripts

  @weekdays ~w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

  # ── paths ─────────────────────────────────────────────────
  # Overridable so tests can run against a tmp diary instead of the live one.
  def diary_root,
    do: Application.get_env(:web, :diary_root) || Path.join(System.user_home!(), ".claude/@log")

  def archive_root, do: Path.join(diary_root(), "archive")

  defp dream_path(date), do: Path.join(diary_root(), "#{date}.dream.md")
  defp notes_path(date), do: Path.join(diary_root(), "#{date}.notes.md")

  # A diary page key is strictly `YYYY-MM-DD`; anything else is a tampered param and
  # must never reach a file path or the dream prompt (which tells claude what to write).
  defp date?(date), do: is_binary(date) and Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, date)

  @doc "Today's date as an ISO string (`YYYY-MM-DD`), the diary's page key."
  def today, do: Date.to_iso8601(Date.utc_today())

  def weekday(date) do
    case Date.from_iso8601(to_string(date)) do
      {:ok, d} -> Enum.at(@weekdays, Date.day_of_week(d) - 1)
      _ -> ""
    end
  end

  # ── listing (the year lookback) ───────────────────────────
  @doc """
  Every day worth showing, newest first: the union of days that have a dream page, a
  notes page, archived transcripts, or live conversations. Each entry is a lightweight
  map — `:date`, `:dreamt?`, `:noted?`, `:archived` count, and a one-line `:preview`.
  """
  def list_days(sessions \\ Transcripts.list_sessions()) do
    archive_days = archive_dates()
    file_days = MapSet.union(page_dates(), archive_days)
    conv_days = session_dates(sessions)

    (MapSet.to_list(file_days) ++ MapSet.to_list(conv_days))
    |> Enum.uniq()
    |> Enum.sort(:desc)
    |> Enum.map(fn date ->
      dream = read_dream(date)

      %{
        archived: (MapSet.member?(archive_days, date) && archived_count(date)) || 0,
        date: date,
        dreamt?: dream != "",
        noted?: read_notes(date) != "",
        preview: preview_of(dream),
        weekday: weekday(date)
      }
    end)
  end

  defp page_dates do
    case File.ls(diary_root()) do
      {:ok, names} ->
        names
        |> Enum.flat_map(fn name ->
          case Regex.run(~r/^(\d{4}-\d{2}-\d{2})\.(dream|notes)\.md$/, name) do
            [_, date, _] -> [date]
            _ -> []
          end
        end)
        |> MapSet.new()

      _ ->
        MapSet.new()
    end
  end

  defp archive_dates do
    case File.ls(archive_root()) do
      {:ok, dirs} -> dirs |> Enum.filter(&date_dir?/1) |> MapSet.new()
      _ -> MapSet.new()
    end
  end

  defp session_dates(sessions) do
    sessions
    |> Enum.map(&day_of/1)
    |> Enum.reject(&is_nil/1)
    |> MapSet.new()
  end

  defp date_dir?(name), do: Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, name)
  defp day_of(%{updated_at: ts}) when is_binary(ts) and ts != "", do: String.slice(ts, 0, 10)
  defp day_of(_), do: nil

  defp preview_of(body) do
    body
    |> String.split("\n", trim: true)
    |> Enum.find("", fn line ->
      not String.starts_with?(line, ["#", "-", "---", "date:", "type:"])
    end)
    |> String.replace(~r/\s+/, " ")
    |> String.slice(0, 140)
  end

  # ── a single day ──────────────────────────────────────────
  @doc "Everything needed to render one day: its dream, notes, and the day's conversations."
  def get_day(date, sessions \\ Transcripts.list_sessions()) do
    if date?(date) do
      %{
        archived: list_archived(date),
        conversations: conversations_on(date, sessions),
        date: date,
        dream: read_dream(date),
        notes: read_notes(date),
        weekday: weekday(date)
      }
    else
      %{archived: [], conversations: [], date: date, dream: "", notes: "", weekday: ""}
    end
  end

  def read_dream(date), do: read_or_empty(dream_path(date))
  def read_notes(date), do: read_or_empty(notes_path(date))

  defp read_or_empty(path) do
    case File.read(path) do
      {:ok, txt} -> txt
      _ -> ""
    end
  end

  @doc "Persist the day's manual notes. Empty text removes the file."
  def write_notes(date, text) do
    if date?(date) do
      File.mkdir_p!(diary_root())
      text = String.trim(to_string(text))

      if text == "",
        do: File.rm(notes_path(date)),
        else: File.write!(notes_path(date), text <> "\n")

      :ok
    else
      {:error, :invalid_date}
    end
  end

  @doc "Live (un-killed) sessions whose last activity fell on `date`, newest first."
  def conversations_on(date, sessions \\ Transcripts.list_sessions()) do
    Enum.filter(sessions, &(day_of(&1) == date))
  end

  # ── compact-delete archive ────────────────────────────────
  @doc "Gzip-archived transcripts compact-deleted on `date` (filenames only)."
  def list_archived(date) do
    dir = Path.join(archive_root(), date)

    case File.ls(dir) do
      {:ok, names} -> names |> Enum.filter(&String.ends_with?(&1, ".jsonl.gz")) |> Enum.sort()
      _ -> []
    end
  end

  defp archived_count(date), do: length(list_archived(date))

  # ── the daily dream (shell out to claude) ─────────────────
  @doc """
  Dream a day: run the dream prompt through the local `claude` CLI, which reads that
  day's conversations and writes `YYYY-MM-DD.dream.md` itself. Returns the CLI's text.
  Slow (a full claude turn) — drive it from a `start_async` in the LiveView.
  """
  def dream(date \\ nil) do
    date = date || today()

    if date?(date) do
      File.mkdir_p!(diary_root())
      tmp = Path.join(System.tmp_dir!(), "claude_dream_#{System.unique_integer([:positive])}.txt")
      File.write!(tmp, dream_prompt(date))
      claude = System.find_executable("claude") || "claude"

      # --no-session-persistence: the dream must not leave its own transcript in
      # ~/.claude/projects — else it clutters Conversations and the next dream summarizes
      # its own dreaming. Print-mode only, which is exactly how we run it.
      {out, _} =
        System.cmd(
          "sh",
          ["-c", ~s('#{claude}' --permission-mode=auto --no-session-persistence -p < '#{tmp}')],
          stderr_to_stdout: true
        )

      File.rm(tmp)
      %{date: date, output: out}
    else
      %{date: date, output: ""}
    end
  end

  @doc """
  The single source-of-truth dream prompt, parameterized by target date. Self-contained
  so it runs identically whether driven from the dashboard (`dream/1`) or unattended by
  the "Daily dream" Routine via launchd. Pass `nil` for a routine that should target the
  current day at run time.
  """
  def dream_prompt(date \\ nil) do
    home = System.user_home!()

    target =
      if date, do: "**#{date}** (#{weekday(date)})", else: "today (compute it with `date +%F`)"

    """
    You are the DAILY DREAM — the diary's nightly distiller. Running UNATTENDED: never
    wait for input or ask questions. Your one job is to write a compact diary page for a
    single day from that day's Claude Code conversations, then stop.

    TARGET DAY: #{target}.

    GATHER the day's conversations (a conversation belongs to the target day if its last
    message timestamp, or failing that the file's modified date, falls on that day):
      - live transcripts:    #{home}/.claude/projects/*/*.jsonl
      - compact-deleted ones: #{home}/.claude/@log/archive/<TARGET-DATE>/*.jsonl.gz  (gunzip to read)
    Each `.jsonl` is one conversation: newline-delimited JSON, user/assistant messages
    under the `message` key. If there are NO conversations for the day, write nothing and
    stop — do not invent a page.

    WRITE exactly one file: `#{home}/.claude/@log/<TARGET-DATE>.dream.md`. Overwrite it
    if it exists (it is regenerable). Touch NOTHING else — never the matching
    `<TARGET-DATE>.notes.md` (those are the human's own notes) and never any transcript.

    FORMAT the page exactly like this (keep it tight — a glance, not a transcript):

        ---
        date: <TARGET-DATE>
        type: dream
        ---

        # <TARGET-DATE> · <Weekday>

        <2–4 sentences: what actually got done across the day, in plain past tense.>

        ## Threads
        - **<project name>** — <one line: what happened in that conversation>
        - …one bullet per meaningful conversation, skip trivial/empty ones…

        ## Worth remembering
        - <0–3 durable lessons that outlive today — the kind of thing you'd `/dissolve`
          into a memory bank. Omit this whole section if nothing qualifies.>

    Write past tense, specific, no filler. Then print one line: the path you wrote and the
    thread count. Stop.
    """
  end
end
