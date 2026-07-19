defmodule Web.UserLogLive do
  use Web, :live_view
  import Web.UI
  alias Core.UserLog

  @months ~w(January February March April May June July August September October November December)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Core.PubSub, "diary")

    {:ok,
     socket
     |> assign(
       page_title: "Diary",
       q: "",
       busy: nil,
       selected: UserLog.today(),
       today: UserLog.today(),
       live?: connected?(socket)
     )
     |> load()}
  end

  defp load(socket) do
    selected = socket.assigns[:selected] || UserLog.today()
    sessions = Core.Transcripts.list_sessions()

    assign(socket,
      days: with_today(UserLog.list_days(sessions)),
      selected: selected,
      day: UserLog.get_day(selected, sessions)
    )
  end

  # Today is always selectable even before it has a page or any conversations.
  defp with_today(days) do
    today = UserLog.today()

    if Enum.any?(days, &(&1.date == today)) do
      days
    else
      [
        %{
          archived: 0,
          date: today,
          dreamt?: false,
          noted?: false,
          preview: "",
          weekday: UserLog.weekday(today)
        }
        | days
      ]
    end
  end

  # ── events ────────────────────────────────────────────────
  @impl true
  def handle_event("search", %{"q" => q}, socket), do: {:noreply, assign(socket, q: q)}

  def handle_event("select", %{"date" => date}, socket),
    do: {:noreply, assign(socket, selected: date, day: UserLog.get_day(date))}

  def handle_event("dream", %{"date" => date}, socket) do
    {:noreply,
     socket
     |> assign(busy: "Dreaming #{date} via claude…")
     |> start_async(:dream, fn -> UserLog.dream(date) end)}
  end

  def handle_event("save_notes", %{"text" => text}, socket) do
    UserLog.write_notes(socket.assigns.selected, text)
    {:noreply, socket |> assign(busy: "Notes saved.") |> load()}
  end

  def handle_event("dissolve", %{"project" => p, "id" => id}, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/memories?dissolve=#{p <> "/" <> id}")}

  @impl true
  def handle_async(:dream, {:ok, %{date: date}}, socket),
    do: {:noreply, socket |> assign(busy: "Dreamt #{date}.", selected: date) |> load()}

  def handle_async(:dream, {:exit, reason}, socket),
    do: {:noreply, assign(socket, busy: "Error: #{inspect(reason)}")}

  @impl true
  def handle_info(:diary_changed, socket), do: {:noreply, load(socket)}

  # ── render ────────────────────────────────────────────────
  @impl true
  def render(assigns) do
    assigns = assign(assigns, groups: grouped(assigns.days, assigns.q))

    ~H"""
    <div class="app">
      <.rail active={:log} />

      <div class="sidebar">
        <header>
          <h1>Diary</h1>
          <span class="live"><span class={["dot", @live? && "on"]} />{if @live?,
            do: "live",
            else: "off"}</span>
        </header>
        <form phx-change="search">
          <input
            class="search"
            name="q"
            value={@q}
            placeholder="Search a day…"
            phx-debounce="120"
          />
        </form>
        <div class="list">
          <div :for={{month, items} <- @groups}>
            <div class="group-label">{month} · {length(items)}</div>
            <div
              :for={d <- items}
              class={["item", @selected == d.date && "active"]}
              phx-click="select"
              phx-value-date={d.date}
              title={d.preview}
            >
              <div class="title">
                {d.weekday} · {short(d.date)}
                <span :if={d.date == @today} class="tag">today</span>
              </div>
              <div class="meta">
                <span :if={d.dreamt?} title="dreamt"><.ph name="moon-stars" /> dream</span>
                <span :if={d.noted?} title="has notes"><.ph name="pencil-simple" /> notes</span>
                <span :if={d.archived > 0}>{d.archived} archived</span>
                <span :if={!d.dreamt? && !d.noted? && d.archived == 0} class="empty-hint">—</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="main">
        <div class="bar">
          <h2>{@day.weekday} · {@day.date}</h2>
          <span class="tag">{length(@day.conversations)} live conversation(s)</span>
          <span :if={@day.archived != []} class="tag">{length(@day.archived)} archived</span>
          <button class="btn dissolve" phx-click="dream" phx-value-date={@day.date}>
            <.ph name="moon-stars" /> {if @day.dream == "", do: "dream this day", else: "re-dream"}
          </button>
        </div>
        <div :if={@busy} class="banner">{@busy}</div>

        <div class="transcript">
          <div class="thread mem">
            <%!-- the daily dream --%>
            <div class="diary-section">
              <div class="diary-label"><.ph name="moon-stars" /> Daily dream</div>
              <%= if @day.dream == "" do %>
                <div class="diary-empty">
                  No dream yet for this day. Press <strong>dream this day</strong> to distill its
                  conversations into a page — or it runs nightly via the “Daily dream” routine.
                </div>
              <% else %>
                <div class="diary-page text">{strip_fm(@day.dream)}</div>
              <% end %>
            </div>

            <%!-- the day's conversations (link out to memory) --%>
            <div :if={@day.conversations != []} class="diary-section">
              <div class="diary-label"><.ph name="chats-circle" /> Conversations</div>
              <div
                :for={s <- @day.conversations}
                class="picker-item"
              >
                <span class="title">{s.title}</span>
                <span class="tag">{project_name(s.cwd)}</span>
                <span class="tag">{rel_time(s.updated_at)}</span>
                <span class="tag">{s.message_count} msgs</span>
                <button
                  class="btn dissolve"
                  phx-click="dissolve"
                  phx-value-project={s.project}
                  phx-value-id={s.id}
                >
                  <.ph name="drop" /> dissolve
                </button>
              </div>
            </div>

            <%!-- manual notes --%>
            <div class="diary-section">
              <div class="diary-label"><.ph name="pencil-simple" /> Notes</div>
              <form phx-submit="save_notes" class="editor">
                <textarea
                  name="text"
                  rows="8"
                  placeholder="What did you do today? Anything to remember…"
                >{@day.notes}</textarea>
                <div class="f-actions">
                  <button type="submit" class="btn ok">save notes</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ── helpers ───────────────────────────────────────────────
  defp grouped(days, q) do
    needle = String.downcase(q)

    filtered =
      Enum.filter(days, fn d ->
        needle == "" or String.contains?(d.date, needle) or
          String.contains?(String.downcase(d.preview), needle) or
          String.contains?(String.downcase(d.weekday), needle)
      end)

    groups = Enum.group_by(filtered, &month_label(&1.date))

    filtered
    |> Enum.map(&month_label(&1.date))
    |> Enum.uniq()
    |> Enum.map(&{&1, groups[&1]})
  end

  defp month_label(<<y::binary-4, "-", m::binary-2, _::binary>>),
    do: "#{Enum.at(@months, String.to_integer(m) - 1)} #{y}"

  defp month_label(date), do: date

  defp short(<<_y::binary-4, "-", m::binary-2, "-", d::binary-2>>),
    do:
      "#{Enum.at(@months, String.to_integer(m) - 1) |> String.slice(0, 3)} #{String.to_integer(d)}"

  defp short(date), do: date

  # Drop a leading `---\n…\n---` frontmatter block for display.
  defp strip_fm(text) do
    case Regex.run(~r/\A---\r?\n.*?\r?\n---\r?\n?(.*)\z/s, text) do
      [_, body] -> String.trim(body)
      _ -> String.trim(text)
    end
  end
end
