defmodule Core.Routines do
  @moduledoc """
  User-defined scheduled routines, each backed by its own macOS launchd
  LaunchAgent. A routine is a name + an unattended `claude` prompt + a schedule;
  it is stored in `~/.claude/@routines/routines.json` and materialized as
  `<slug>.sh` / `<slug>.prompt.txt` / `com.claude.routines.<slug>.plist`.

  launchd *is* the scheduler — nothing runs inside the BEAM. This module reads and
  manages the agents through `launchctl`, mirroring `Core.Memory`'s habit of
  shelling out to `claude` and keeping plain files under `~/.claude`.
  """

  @default_update_prompt """
  You are running UNATTENDED on a schedule — no human is watching, so never wait for input or ask questions.

  For each tool below: read the installed version, then the latest released version. If they match, do nothing. If a newer version exists, FETCH its changelog for the gap between installed and latest and assess risk. Apply the update ONLY when the changelog shows no breaking changes; if it shows a breaking change, SKIP the update and log one line explaining why. Print a one-line result per tool.

  - claude (Claude Code)
    installed:  claude --version
    latest:     curl -fsSL https://downloads.claude.ai/claude-code-releases/latest
    changelog:  https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md
    update:     claude update

  - mise
    installed:  mise version
    latest:     https://api.github.com/repos/jdx/mise/releases/latest (the tag_name field)
    changelog:  https://github.com/jdx/mise/releases/tag/<tag_name>
    update:     mise self-update --yes\
  """

  @default_routines [
    %{
      "name" => "Update tools",
      "prompt" => @default_update_prompt,
      "schedule" => %{"seconds" => 21_600, "type" => "interval"},
      "slug" => "update"
    }
  ]

  # Built at runtime so the "Daily dream" carries `Core.UserLog`'s live prompt — the
  # same one the dashboard's "dream now" button runs. launchd fires it nightly, unattended.
  defp default_routines do
    @default_routines ++
      [
        %{
          "name" => "Daily dream",
          "prompt" => Core.UserLog.dream_prompt(),
          "schedule" => %{"hour" => 23, "minute" => 30, "type" => "daily"},
          "slug" => "daily-dream"
        }
      ]
  end

  @units %{"d" => 86_400, "h" => 3600, "m" => 60, "s" => 1}
  @weekdays ~w(sun mon tue wed thu fri sat)

  # ── definitions store ─────────────────────────────────────
  def list do
    Enum.map(read_routines(), fn r ->
      slug = r["slug"]

      Map.merge(r, %{
        "installed" => File.exists?(plist_path(slug)),
        "last_run" => last_run(slug),
        "loaded" => loaded?(slug),
        "log" => log_tail(slug)
      })
    end)
  end

  def get(slug), do: Enum.find(read_routines(), &(&1["slug"] == slug))

  @doc "Validate params, persist a new routine, and load its agent."
  def create(params) do
    with {:ok, attrs} <- validate(params) do
      slug = slugify(attrs.name)

      if Enum.any?(read_routines(), &(&1["slug"] == slug)) do
        {:error, "a routine named “#{attrs.name}” already exists"}
      else
        routine = %{
          "name" => attrs.name,
          "prompt" => attrs.prompt,
          "schedule" => attrs.schedule,
          "slug" => slug
        }

        write_routines(read_routines() ++ [routine])
        install_agent(routine)
        {:ok, routine}
      end
    end
  end

  @doc "Update an existing routine (slug stays fixed) and reload its agent."
  def update(slug, params) do
    with {:ok, attrs} <- validate(params) do
      routines = read_routines()

      case Enum.find(routines, &(&1["slug"] == slug)) do
        nil ->
          {:error, "routine not found"}

        old ->
          routine = %{
            old
            | "name" => attrs.name,
              "prompt" => attrs.prompt,
              "schedule" => attrs.schedule
          }

          write_routines(Enum.map(routines, &if(&1["slug"] == slug, do: routine, else: &1)))
          install_agent(routine)
          {:ok, routine}
      end
    end
  end

  @doc "Unload + remove a routine and all of its files."
  def delete(slug) do
    if Core.Store.component?(slug) do
      if loaded?(slug), do: bootout(slug)

      Enum.each(
        [
          plist_path(slug),
          script_path(slug),
          prompt_path(slug),
          result_path(slug),
          log_path(slug)
        ],
        &File.rm/1
      )

      write_routines(Enum.reject(read_routines(), &(&1["slug"] == slug)))
      :ok
    else
      {:error, :invalid_slug}
    end
  end

  @doc "Force a routine to run now, loading its agent first if needed."
  def run_now(slug) do
    if Core.Store.component?(slug) do
      if (r = get(slug)) && not loaded?(slug), do: install_agent(r)

      {out, code} =
        System.cmd("launchctl", ["kickstart", "-k", service(slug)], stderr_to_stdout: true)

      if code == 0, do: :ok, else: {:error, String.trim(out)}
    else
      {:error, :invalid_slug}
    end
  end

  # ── form params <-> schedule ──────────────────────────────
  def new_form_params, do: %{"name" => "", "prompt" => "", "schedule" => "every 6h"}

  def to_form_params(r),
    do: %{
      "name" => r["name"],
      "prompt" => r["prompt"],
      "schedule" => humanize_schedule(r["schedule"])
    }

  def schedule_label(schedule), do: humanize_schedule(schedule)

  def humanize_schedule(%{"type" => "interval", "seconds" => s}) when is_integer(s) do
    cond do
      rem(s, 86_400) == 0 -> "every #{div(s, 86_400)}d"
      rem(s, 3600) == 0 -> "every #{div(s, 3600)}h"
      rem(s, 60) == 0 -> "every #{div(s, 60)}m"
      true -> "every #{s}s"
    end
  end

  def humanize_schedule(%{"type" => "daily", "hour" => h, "minute" => m} = s) do
    prefix = if days = weekdays_of(s), do: day_phrase(days), else: "daily"
    "#{prefix} at #{pad(h)}:#{pad(m)}"
  end

  def humanize_schedule(_), do: "—"

  defp weekdays_of(%{"weekdays" => list}) when is_list(list), do: list
  defp weekdays_of(%{"weekday" => w}) when is_integer(w), do: [w]
  defp weekdays_of(_), do: nil

  defp day_phrase(days) do
    ds = days |> Enum.uniq() |> Enum.sort_by(&week_index/1)
    idx = Enum.map(ds, &week_index/1)
    consecutive? = idx == Enum.to_list(List.first(idx)..List.last(idx))

    if length(ds) > 2 and consecutive?,
      do: "#{Enum.at(@weekdays, List.first(ds))}-#{Enum.at(@weekdays, List.last(ds))}",
      else: Enum.map_join(ds, ",", &Enum.at(@weekdays, &1))
  end

  # display ordering: Monday = 0 … Sunday = 6 (launchd stores Sunday = 0)
  defp week_index(d), do: rem(d + 6, 7)

  # ── status helpers ────────────────────────────────────────
  def label(slug), do: "com.claude.routines.#{slug}"
  def script_path(slug), do: Path.join(routines_dir(), "#{slug}.sh")
  def log_path(slug), do: Path.join(routines_dir(), "#{slug}.log")
  def plist_path(slug), do: Path.join(home(), "Library/LaunchAgents/#{label(slug)}.plist")

  def loaded?(slug) do
    {_out, code} = System.cmd("launchctl", ["print", service(slug)], stderr_to_stdout: true)
    code == 0
  end

  def log_tail(slug, lines \\ 300) do
    case File.read(log_path(slug)) do
      {:ok, txt} -> txt |> String.split("\n") |> Enum.take(-lines) |> Enum.join("\n")
      _ -> ""
    end
  end

  defp last_run(slug) do
    with {:ok, txt} <- File.read(result_path(slug)),
         {:ok, map} <- Jason.decode(txt) do
      map
    else
      _ -> nil
    end
  end

  # ── internals ─────────────────────────────────────────────
  defp validate(p) do
    name = String.trim(p["name"] || "")
    prompt = String.trim(p["prompt"] || "")

    cond do
      name == "" ->
        {:error, "name is required"}

      prompt == "" ->
        {:error, "prompt is required"}

      slugify(name) == "" ->
        {:error, "name must contain letters or numbers"}

      true ->
        with sched when is_map(sched) <- parse_schedule_string(p["schedule"]),
             do: {:ok, %{name: name, prompt: prompt, schedule: sched}}
    end
  end

  @doc """
  Parse a schedule string into a schedule map, or return `{:error, message}`:

      every 6h · every 30m · every 90s · every 1d   → interval
      daily at 09:00 · 23:00 · mon at 14:30          → calendar
  """
  def parse_schedule_string(str) do
    s = str |> to_string() |> String.trim() |> String.downcase()

    cond do
      s == "" -> {:error, "schedule is required"}
      String.starts_with?(s, "every") -> parse_every(s)
      true -> parse_calendar(s)
    end
  end

  defp parse_every(s) do
    case Regex.run(~r/^every\s+(\d+)\s*([smhd])$/, s) do
      [_, n, u] when n != "0" ->
        %{"seconds" => String.to_integer(n) * @units[u], "type" => "interval"}

      _ ->
        {:error, "try: every 6h · every 30m · every 90s · every 1d"}
    end
  end

  defp parse_calendar(s0) do
    # tighten "mon , wed" / "mon - fri" into "mon,wed" / "mon-fri" so the dayspec is one token
    s =
      s0
      |> String.replace(~r/\s*([,-])\s*/, "\\1")
      |> String.replace(~r/\bat\b/, " ")
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    {wd_token, time_token} =
      case String.split(s, " ") do
        [t] -> {nil, t}
        [w, t] -> {w, t}
        _ -> {:invalid, :invalid}
      end

    with true <- wd_token != :invalid,
         {:ok, {h, m}} <- parse_time(time_token),
         {:ok, days} <- parse_weekdays(wd_token) do
      daily = %{"hour" => h, "minute" => m, "type" => "daily"}
      if days, do: Map.put(daily, "weekdays", days), else: daily
    else
      _ -> {:error, "try: daily at 09:00 · mon at 14:30 · mon-fri at 09:00 · sat,sun at 10:00"}
    end
  end

  defp parse_time(t) do
    with [hh, mm] <- String.split(t, ":"),
         {h, ""} <- Integer.parse(hh),
         {m, ""} <- Integer.parse(mm),
         true <- h in 0..23 and m in 0..59 do
      {:ok, {h, m}}
    else
      _ -> :error
    end
  end

  defp parse_weekdays(token) when token in [nil, "daily", "everyday"], do: {:ok, nil}
  defp parse_weekdays("weekdays"), do: {:ok, [1, 2, 3, 4, 5]}
  defp parse_weekdays("weekends"), do: {:ok, [0, 6]}

  defp parse_weekdays(spec) do
    spec
    |> String.split(",")
    |> Enum.reduce_while([], fn part, acc ->
      case expand_part(part) do
        {:ok, days} -> {:cont, acc ++ days}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      days -> {:ok, days |> Enum.uniq() |> Enum.sort()}
    end
  end

  defp expand_part(part) do
    case String.split(part, "-") do
      [d] ->
        case day_index(d) do
          nil -> :error
          i -> {:ok, [i]}
        end

      [a, b] ->
        case {day_index(a), day_index(b)} do
          {ai, bi} when is_integer(ai) and is_integer(bi) -> {:ok, day_range(ai, bi)}
          _ -> :error
        end

      _ ->
        :error
    end
  end

  defp day_index(d), do: Enum.find_index(@weekdays, &(&1 == String.slice(d, 0, 3)))
  defp day_range(a, b) when a <= b, do: Enum.to_list(a..b)
  defp day_range(a, b), do: Enum.to_list(a..6) ++ Enum.to_list(0..b)

  defp install_agent(r) do
    slug = r["slug"]
    File.mkdir_p!(routines_dir())
    File.write!(prompt_path(slug), r["prompt"])
    File.write!(script_path(slug), script_for(slug))
    File.chmod!(script_path(slug), 0o755)
    File.mkdir_p!(Path.dirname(plist_path(slug)))
    File.write!(plist_path(slug), plist_for(slug, r["schedule"]))
    if loaded?(slug), do: bootout(slug)
    System.cmd("launchctl", ["bootstrap", domain(), plist_path(slug)], stderr_to_stdout: true)
  end

  defp bootout(slug),
    do: System.cmd("launchctl", ["bootout", service(slug)], stderr_to_stdout: true)

  defp read_routines do
    case File.read(routines_file()) do
      {:error, :enoent} ->
        default_routines()

      {:ok, txt} ->
        case Jason.decode(txt) do
          {:ok, list} when is_list(list) ->
            list

          # File exists but won't parse (torn/corrupt write). Do NOT fall back to
          # defaults — that would make the next create/update/delete persist
          # defaults-plus-edit and permanently erase the real routines. Fail loud.
          _ ->
            raise "routines.json is unreadable — refusing to overwrite it with defaults"
        end

      {:error, reason} ->
        raise "cannot read routines.json: #{inspect(reason)}"
    end
  end

  defp write_routines(list) do
    Core.Store.write!(routines_file(), Jason.encode!(list, pretty: true))
  end

  defp slugify(name),
    do:
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.trim("-")
      |> String.slice(0, 50)

  defp pad(n), do: n |> to_string() |> String.pad_leading(2, "0")

  # ── paths ─────────────────────────────────────────────────
  defp home, do: System.user_home!()
  defp routines_dir, do: Path.join(home(), ".claude/@routines")
  defp routines_file, do: Path.join(routines_dir(), "routines.json")
  defp result_path(slug), do: Path.join(routines_dir(), "#{slug}.last-run.json")
  defp prompt_path(slug), do: Path.join(routines_dir(), "#{slug}.prompt.txt")

  defp uid, do: "id" |> System.cmd(["-u"]) |> elem(0) |> String.trim()
  defp domain, do: "gui/#{uid()}"
  defp service(slug), do: "#{domain()}/#{label(slug)}"

  # ── generated files ───────────────────────────────────────
  # `$HOME`/`$START`/… are bash expansions (Elixir only interpolates `#\{}`); the
  # prompt is read from a sibling file via "$(cat …)" so arbitrary prompt text can
  # never break the script's quoting. JSON is written with a heredoc (no escapes).
  defp script_for(slug) do
    """
    #!/usr/bin/env bash
    set -uo pipefail
    export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

    DIR="#{routines_dir()}"
    START="$(date +%Y-%m-%dT%H:%M:%S%z)"
    echo "──────── #{slug} · started $START ────────"

    # --no-session-persistence: unattended runs shouldn't leave transcripts cluttering
    # the human's Conversations view (and the daily-dream must not summarize its own run).
    claude --permission-mode=auto --no-session-persistence -p "$(cat "$DIR/#{slug}.prompt.txt")"
    CODE=$?

    END="$(date +%Y-%m-%dT%H:%M:%S%z)"
    cat > "$DIR/#{slug}.last-run.json" <<EOF
    {"started":"$START","finished":"$END","exit":$CODE}
    EOF
    echo "──────── done · exit $CODE · $END ────────"
    exit $CODE
    """
  end

  defp plist_for(slug, schedule) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key><string>#{label(slug)}</string>
      <key>ProgramArguments</key>
      <array>
        <string>/bin/bash</string>
        <string>#{script_path(slug)}</string>
      </array>
    #{schedule_plist(schedule)}  <key>RunAtLoad</key><false/>
      <key>ProcessType</key><string>Background</string>
      <key>StandardOutPath</key><string>#{log_path(slug)}</string>
      <key>StandardErrorPath</key><string>#{log_path(slug)}</string>
      <key>EnvironmentVariables</key>
      <dict>
        <key>HOME</key><string>#{home()}</string>
        <key>PATH</key><string>#{home()}/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
      </dict>
    </dict>
    </plist>
    """
  end

  defp schedule_plist(%{"type" => "daily", "hour" => h, "minute" => m} = s) do
    body =
      case weekdays_of(s) do
        nil -> cal_dict(h, m, nil)
        [day] -> cal_dict(h, m, day)
        days -> "<array>" <> Enum.map_join(days, &cal_dict(h, m, &1)) <> "</array>"
      end

    "  <key>StartCalendarInterval</key>\n  #{body}\n"
  end

  defp schedule_plist(%{"type" => "interval", "seconds" => s}),
    do: "  <key>StartInterval</key><integer>#{s}</integer>\n"

  defp cal_dict(h, m, nil),
    do:
      "<dict><key>Hour</key><integer>#{h}</integer><key>Minute</key><integer>#{m}</integer></dict>"

  defp cal_dict(h, m, wd),
    do:
      "<dict><key>Hour</key><integer>#{h}</integer><key>Minute</key><integer>#{m}</integer><key>Weekday</key><integer>#{wd}</integer></dict>"
end
