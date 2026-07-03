defmodule Web.ConversationsLive do
  use Web, :live_view
  import Web.UI
  alias Core.Transcripts

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Core.PubSub, "transcripts")

    {:ok,
     socket
     |> assign(
       page_title: "Conversations",
       q: "",
       selected: nil,
       session: nil,
       live?: connected?(socket)
     )
     |> assign(sessions: Transcripts.list_sessions())}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket), do: {:noreply, assign(socket, q: q)}

  def handle_event("select", %{"project" => p, "id" => id}, socket),
    do: {:noreply, assign(socket, selected: {p, id}, session: Transcripts.get_session(p, id))}

  def handle_event("dissolve", %{"project" => p, "id" => id}, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/memories?dissolve=#{p <> "/" <> id}")}

  def handle_event("delete", %{"project" => p, "id" => id}, socket) do
    Transcripts.delete_session(p, id)
    {:noreply, assign(socket, selected: nil, session: nil, sessions: Transcripts.list_sessions())}
  end

  @impl true
  def handle_info({:session_changed, p, id}, socket) do
    socket = assign(socket, sessions: Transcripts.list_sessions())

    socket =
      if socket.assigns.selected == {p, id},
        do: assign(socket, session: Transcripts.get_session(p, id)),
        else: socket

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, groups: grouped(assigns.sessions, assigns.q))

    ~H"""
    <div class="app">
      <.rail active={:conversations} />

      <div class="sidebar">
        <header>
          <h1>Conversations</h1>
          <span class="live"><span class={["dot", @live? && "on"]} />{if @live?,
            do: "live",
            else: "off"}</span>
        </header>
        <form phx-change="search">
          <input
            class="search"
            style="width: calc(100% - 24px)"
            name="q"
            value={@q}
            placeholder="Search title or path…"
            phx-debounce="120"
          />
        </form>
        <div class="list">
          <div :for={{name, items} <- @groups}>
            <div class="group-label" title={List.first(items).cwd}>{name} · {length(items)}</div>
            <div
              :for={s <- items}
              class={[
                "item",
                (match?({_, _}, @selected) and @selected == {s.project, s.id}) && "active"
              ]}
              phx-click="select"
              phx-value-project={s.project}
              phx-value-id={s.id}
            >
              <div class="title">{s.title}</div>
              <div class="meta">
                <span>{rel_time(s.updated_at)}</span>
                <span>{s.message_count} msgs</span>
                <span>{fmt_tokens(s.tokens.input + s.tokens.output)} tok</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div :if={@session} class="main">
        <div class="bar">
          <h2>{@session.title}</h2>
          <span class="tag">{project_name(@session.cwd)}</span>
          <span :if={@session.branch} class="tag">⌥ {@session.branch}</span>
          <span class="tag">{@session.message_count} msgs</span>
          <span class="tag">
            ↑{fmt_tokens(@session.tokens.input)} ↓{fmt_tokens(@session.tokens.output)} ⚡{fmt_tokens(
              @session.tokens.cache_read
            )}
          </span>
          <span :if={@session.model} class="tag">{@session.model}</span>
          <button
            class="btn dissolve"
            phx-click="dissolve"
            phx-value-project={@session.project}
            phx-value-id={@session.id}
          >
            <.ph name="drop" /> dissolve → memory
          </button>
          <button
            class="btn warn"
            phx-click="delete"
            phx-value-project={@session.project}
            phx-value-id={@session.id}
            data-confirm={"Compact-delete “#{@session.title}”? The transcript is gzip-archived to the diary, then removed — the session is no longer resumable."}
          >
            <.ph name="trash" /> delete
          </button>
        </div>
        <div class="transcript">
          <div class="thread">
            <.message :for={m <- Enum.reject(@session.messages, & &1.is_meta)} msg={m} />
          </div>
        </div>
      </div>
      <div :if={!@session} class="main">
        <div class="empty">Select a conversation</div>
      </div>
    </div>
    """
  end

  defp grouped(sessions, q) do
    needle = String.downcase(q)

    sessions
    |> Enum.filter(fn s ->
      needle == "" or String.contains?(String.downcase(s.title), needle) or
        String.contains?(String.downcase(s.cwd), needle)
    end)
    |> Enum.reduce([], fn s, acc ->
      name = project_name(s.cwd)

      case List.keyfind(acc, name, 0) do
        {^name, items} -> List.keyreplace(acc, name, 0, {name, items ++ [s]})
        nil -> acc ++ [{name, [s]}]
      end
    end)
  end
end
