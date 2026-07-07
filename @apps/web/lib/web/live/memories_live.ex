defmodule Web.MemoriesLive do
  use Web, :live_view
  import Web.UI
  alias Core.{Memory, Transcripts}

  @types ~w(feedback project reference user)

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Core.PubSub, "memory")

    socket =
      socket
      |> assign(
        page_title: "Memory",
        editing: nil,
        selected: MapSet.new(),
        busy: nil,
        steering: nil,
        picker: nil,
        active_id: nil
      )
      |> reload()

    socket =
      with id when is_binary(id) <- params["dissolve"],
           true <- connected?(socket),
           [p, sid] <- String.split(id, "/", parts: 2) do
        start_dissolve(socket, p, sid)
      else
        _ -> socket
      end

    {:ok, socket}
  end

  defp reload(socket) do
    banks = Memory.list_banks()
    active = socket.assigns[:active_id] || (List.first(banks) && List.first(banks).id)
    assign(socket, banks: banks, active_id: active)
  end

  defp active_bank(%{banks: banks, active_id: id}),
    do: Enum.find(banks, &(&1.id == id)) || List.first(banks)

  defp staged(bank), do: Enum.filter(bank.memories, &(&1[:staged] == true))
  defp committed(bank), do: Enum.reject(bank.memories, &(&1[:staged] == true))

  # ── events ────────────────────────────────────────────────
  @impl true
  def handle_event("select_bank", %{"id" => id}, socket),
    do: {:noreply, assign(socket, active_id: id, selected: MapSet.new(), editing: nil)}

  def handle_event("edit", %{"name" => name}, socket) do
    # The memory can vanish between render and click (a watch-reload, another tab, or an
    # async distill that just re-staged) — Map.put(nil, …) would crash the socket.
    case Enum.find(active_bank(socket.assigns).memories, &(&1.name == name)) do
      nil ->
        {:noreply, socket}

      memory ->
        {:noreply, assign(socket, editing: Map.put(memory, :staged, memory[:staged] == true))}
    end
  end

  def handle_event("cancel_edit", _, socket), do: {:noreply, assign(socket, editing: nil)}

  def handle_event("save", params, socket) do
    memory = %{
      bank: params["bank"],
      body: params["body"],
      description: params["description"],
      name: params["name"],
      replaces: replaces_for(params),
      source: nz(params["source"]),
      type: params["type"]
    }

    Memory.commit_memory(memory)
    {:noreply, socket |> assign(editing: nil) |> reload()}
  end

  def handle_event("approve", %{"name" => name}, socket) do
    bank = active_bank(socket.assigns)
    if f = Enum.find(staged(bank), &(&1.name == name)), do: Memory.commit_memory(f)
    {:noreply, reload(socket)}
  end

  def handle_event("reject", %{"name" => name}, socket) do
    Memory.reject_staged(active_bank(socket.assigns).id, name)
    {:noreply, reload(socket)}
  end

  def handle_event("delete", %{"file" => file}, socket) do
    Memory.delete_memory(active_bank(socket.assigns).id, file)
    {:noreply, reload(socket)}
  end

  def handle_event("toggle", %{"file" => file}, socket) do
    sel = socket.assigns.selected

    {:noreply,
     assign(socket,
       selected:
         if(MapSet.member?(sel, file), do: MapSet.delete(sel, file), else: MapSet.put(sel, file))
     )}
  end

  def handle_event("merge", _, socket) do
    bank = active_bank(socket.assigns)
    files = MapSet.to_list(socket.assigns.selected)

    {:noreply,
     socket
     |> assign(busy: "Merging via claude…", selected: MapSet.new())
     |> start_async(:merge, fn -> Memory.merge_memories(bank.id, files) end)}
  end

  def handle_event("open_steering", _, socket),
    do: {:noreply, assign(socket, steering: Memory.get_steering())}

  def handle_event("close_steering", _, socket), do: {:noreply, assign(socket, steering: nil)}

  def handle_event("save_steering", %{"text" => text}, socket) do
    Memory.set_steering(text)
    {:noreply, assign(socket, steering: nil)}
  end

  def handle_event("open_picker", _, socket),
    do: {:noreply, assign(socket, picker: Transcripts.list_sessions())}

  def handle_event("close_picker", _, socket), do: {:noreply, assign(socket, picker: nil)}

  def handle_event("distill", %{"project" => p, "id" => id}, socket),
    do: {:noreply, start_dissolve(socket, p, id)}

  # Distill the whole conversation, then compact-delete its source transcript
  # (consume-on-dissolve; the transcript is gzip-archived to the diary, not erased).
  # Guard first: project/id are client-controlled (URL param, phx-value) so reject path
  # traversal, and a stale list (or a non-persisted dream run) can point at a transcript
  # that's already gone — dissolving that would crash distill_session with "session not
  # found". Only consume the transcript when extraction produced memories: an empty result
  # is indistinguishable from a failed `claude` run, and there is nothing to review.
  defp start_dissolve(socket, project, id) do
    if path_component?(project) and path_component?(id) and Transcripts.get_session(project, id) do
      socket
      |> assign(busy: "Dissolving via claude…", picker: nil)
      |> start_async(:distill, fn ->
        result = Memory.distill_session(project, id)
        if result.memories != [], do: Transcripts.delete_session(project, id)
        result
      end)
    else
      assign(socket,
        busy:
          "That conversation no longer exists — it may have been dissolved, deleted, or archived.",
        picker: nil
      )
    end
  end

  # ── async (slow claude calls) ─────────────────────────────
  @impl true
  def handle_async(:distill, {:ok, %{bank: bank, memories: memories} = result}, socket) do
    msg =
      cond do
        result[:staged] && result.staged > 0 ->
          "Judge unavailable — #{result.staged} candidate(s) staged for review."

        memories == [] ->
          "No durable memories found in that conversation."

        true ->
          "#{length(memories)} #{(length(memories) == 1 && "memory") || "memories"} committed" <>
            if(result[:dropped] && result.dropped > 0,
              do: " · #{result.dropped} dropped by the judge.",
              else: "."
            )
      end

    {:noreply, socket |> assign(busy: msg, active_id: bank) |> reload()}
  end

  def handle_async(:merge, {:ok, _}, socket),
    do: {:noreply, socket |> assign(busy: "Merged candidate staged for review.") |> reload()}

  def handle_async(_, {:exit, reason}, socket),
    do: {:noreply, assign(socket, busy: "Error: #{inspect(reason)}")}

  @impl true
  def handle_info(:memory_changed, socket), do: {:noreply, reload(socket)}

  defp replaces_for(%{"staged" => "true", "replaces" => r}) when is_binary(r),
    do: Jason.decode!(r)

  defp replaces_for(%{"orig_file" => f}) when f not in [nil, ""], do: [f]
  defp replaces_for(_), do: nil

  defp nz(""), do: nil
  defp nz(v), do: v

  defp path_component?(s),
    do: is_binary(s) and s != "" and Path.basename(s) == s and not String.contains?(s, "..")

  # ── render ────────────────────────────────────────────────
  @impl true
  def render(assigns) do
    assigns = assign(assigns, active: active_bank(assigns))

    ~H"""
    <div class="app">
      <.rail active={:memories} />

      <div class="sidebar">
        <header>
          <h1>Memory Banks</h1>
        </header>
        <div class="bank-actions">
          <button class="btn wide" phx-click="open_picker"><.ph name="drop" /> Dissolve a conversation</button>
          <button class="btn wide" phx-click="open_steering"><.ph name="gear-six" />
          Steering instructions</button>
        </div>
        <div class="list">
          <div :for={kind <- [:managed, :auto]}>
            <% group = Enum.filter(@banks, &(&1.kind == kind)) %>
            <div :if={group != []}>
              <div class="group-label">
                {if kind == :managed,
                  do: "Managed · dissolved",
                  else: "Auto · Claude Code (read-only)"}
              </div>
              <div
                :for={b <- group}
                class={["item", @active && @active.id == b.id && "active"]}
                phx-click="select_bank"
                phx-value-id={b.id}
                title={b.label}
              >
                <div class="title">{b.label}</div>
                <div class="meta">
                  <span>{length(committed(b))} memories</span>
                  <% pend = length(staged(b)) %>
                  <span :if={pend > 0} class="staged-count">{pend} pending</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="main">
        <div class="bar">
          <h2>{(@active && @active.label) || "Memory"}</h2>
          <span class="tag">{if @active && @active.readonly,
            do: "auto · Claude Code · read-only",
            else: "managed · you steer this"}</span>
          <span :if={@active} class="tag">{length(committed(@active))} memories</span>
          <button
            :if={@active && !@active.readonly && MapSet.size(@selected) >= 2}
            class="btn ok"
            phx-click="merge"
          >
            <.ph name="arrows-merge" /> merge {MapSet.size(@selected)}
          </button>
        </div>
        <div :if={@busy} class="banner">{@busy}</div>

        <div class="transcript">
          <div class="thread mem">
            <div :if={@active && staged(@active) != []} class="stage">
              <div class="stage-label">Review queue · {length(staged(@active))} candidate(s)</div>
              <%= for f <- staged(@active) do %>
                <.memory_editor :if={editing?(@editing, f, true)} memory={@editing} />
                <.memory_card :if={!editing?(@editing, f, true)} memory={f} mode={:staged} />
              <% end %>
            </div>

            <div :if={@active && committed(@active) == [] && staged(@active) == []} class="empty-mem">
              {if @active.readonly,
                do: "This auto-memory bank is empty.",
                else: "This bank is empty. Dissolve a conversation to populate it."}
            </div>

            <%= if @active do %>
              <%= for f <- committed(@active) do %>
                <.memory_editor :if={editing?(@editing, f, false)} memory={@editing} />
                <.memory_card
                  :if={!editing?(@editing, f, false)}
                  memory={f}
                  mode={if @active.readonly, do: :readonly, else: :committed}
                  selected={MapSet.member?(@selected, f.file)}
                />
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <div :if={@steering} class="modal-bg" phx-click="close_steering">
        <div class="modal" phx-click-away="close_steering" onclick="event.stopPropagation()">
          <h3>Steering instructions</h3>
          <p class="hint">
            Guides every dissolve. The whole conversation is always fed — these tune what's kept.
          </p>
          <form phx-submit="save_steering" style="display:flex;flex-direction:column;gap:10px">
            <textarea name="text" rows="16">{@steering}</textarea>
            <div class="f-actions">
              <button type="button" class="btn" phx-click="close_steering">cancel</button>
              <button type="submit" class="btn ok">save</button>
            </div>
          </form>
        </div>
      </div>

      <div :if={@picker} class="modal-bg" phx-click="close_picker">
        <div class="modal wide-modal" onclick="event.stopPropagation()">
          <h3>Dissolve a conversation into memory</h3>
          <p class="hint">
            The entire conversation is distilled — never a fragment — then judge-verified and committed to its project's bank automatically.
          </p>
          <div class="picker-list">
            <div
              :for={s <- @picker}
              class="picker-item"
              phx-click="distill"
              phx-value-project={s.project}
              phx-value-id={s.id}
            >
              <span class="title">{s.title}</span>
              <span class="tag">{project_name(s.cwd)}</span>
              <span class="tag">{rel_time(s.updated_at)}</span>
              <span class="tag">{s.message_count} msgs</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp editing?(nil, _f, _staged?), do: false
  defp editing?(e, f, true), do: e[:staged] == true and e.name == f.name
  defp editing?(e, f, false), do: e[:staged] != true and e.file == f.file

  # ── memory components ───────────────────────────────────────
  attr :memory, :map, required: true
  attr :mode, :atom, required: true
  attr :selected, :boolean, default: false

  defp memory_card(assigns) do
    ~H"""
    <div class={["memory", @mode == :staged && "staged", @selected && "sel"]}>
      <div class="memory-head">
        <input
          :if={@mode == :committed}
          type="checkbox"
          phx-click="toggle"
          phx-value-file={@memory.file}
          checked={@selected}
        />
        <span class={["badge", @memory.type]}>{@memory.type}</span>
        <span class="memory-name">{@memory.name}</span>
        <span :if={@mode == :staged} class="badge staged-b">candidate</span>
        <span :if={@memory[:replaces] not in [nil, []]} class="badge merge-b">merges {length(
          @memory.replaces
        )}</span>
        <div class="memory-tools">
          <button
            :if={@mode == :staged}
            class="btn ok"
            phx-click="approve"
            phx-value-name={@memory.name}
            title="Approve"
          ><.ph name="check" /></button>
          <button
            :if={@mode != :readonly}
            class="btn"
            phx-click="edit"
            phx-value-name={@memory.name}
            title="Edit"
          ><.ph name="pencil-simple" /></button>
          <button
            :if={@mode == :staged}
            class="btn warn"
            phx-click="reject"
            phx-value-name={@memory.name}
            title="Reject"
          ><.ph name="x" /></button>
          <button
            :if={@mode == :committed}
            class="btn warn"
            phx-click="delete"
            phx-value-file={@memory.file}
            data-confirm={"Delete “#{@memory.name}”?"}
            title="Delete"
          ><.ph name="trash" /></button>
        </div>
      </div>
      <div class="memory-desc">{@memory.description}</div>
      <div class="memory-body">{@memory.body}</div>
    </div>
    """
  end

  attr :memory, :map, required: true

  defp memory_editor(assigns) do
    assigns = assign(assigns, types: @types)

    ~H"""
    <form class="editor" phx-submit="save">
      <input type="hidden" name="bank" value={@memory.bank} />
      <input type="hidden" name="orig_file" value={@memory[:file] || ""} />
      <input type="hidden" name="staged" value={to_string(@memory[:staged] == true)} />
      <input type="hidden" name="source" value={@memory[:source] || ""} />
      <input type="hidden" name="replaces" value={Jason.encode!(@memory[:replaces])} />
      <input class="f-name" name="name" value={@memory.name} placeholder="human-readable title" />
      <input name="description" value={@memory.description} placeholder="one-line recall summary" />
      <select name="type">
        <option :for={t <- @types} selected={t == @memory.type}>{t}</option>
      </select>
      <textarea name="body" rows="9">{@memory.body}</textarea>
      <div class="f-actions">
        <button type="button" class="btn" phx-click="cancel_edit">cancel</button>
        <button type="submit" class="btn ok">save</button>
      </div>
    </form>
    """
  end
end
