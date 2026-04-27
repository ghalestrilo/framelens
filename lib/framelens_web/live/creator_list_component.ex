defmodule FramelensWeb.CreatorListComponent do
  use FramelensWeb, :live_component

  @page_size 5

  @doc """
  Renders a paginated list of creators with follow/unfollow buttons.

  Required assigns:
    - id
    - creators: full list of %{id, name, follow_count} maps
    - followed_ids: MapSet of creator ids the current user already follows
    - on_follow: event name to send to the parent when a creator is followed
    - on_unfollow: event name to send to the parent when a creator is unfollowed
  """
  def update(assigns, socket) do
    visible = Enum.take(assigns.creators, @page_size)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       visible: visible,
       has_more: length(visible) < length(assigns.creators)
     )}
  end

  def handle_event("load_more", _params, socket) do
    next_count = length(socket.assigns.visible) + @page_size
    visible = Enum.take(socket.assigns.creators, next_count)
    has_more = length(visible) < length(socket.assigns.creators)
    {:noreply, assign(socket, visible: visible, has_more: has_more)}
  end

  def handle_event("follow", %{"id" => creator_id}, socket) do
    send(self(), {socket.assigns.on_follow, String.to_integer(creator_id)})
    {:noreply, socket}
  end

  def handle_event("unfollow", %{"id" => creator_id}, socket) do
    send(self(), {socket.assigns.on_unfollow, String.to_integer(creator_id)})
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook=".InfiniteScroll" phx-target={@myself}>
      <ul class="flex flex-col gap-3 w-full">
        <li
          :for={creator <- @visible}
          class="flex items-center justify-between rounded-lg border border-base-300 px-4 py-3 gap-4"
        >
          <div class="flex items-baseline justify-between flex-1">
            <span class="font-medium">{creator.name}</span>
            <span class="ml-2 text-sm text-base-content/50">
              {creator.follow_count} {if creator.follow_count == 1, do: "follower", else: "followers"}
            </span>
          </div>
          <%= if MapSet.member?(@followed_ids, creator.id) do %>
            <button
              phx-click="unfollow"
              phx-value-id={creator.id}
              phx-target={@myself}
              class="btn btn-sm btn-ghost text-error"
            >
              Unfollow
            </button>
          <% else %>
            <button
              phx-click="follow"
              phx-value-id={creator.id}
              phx-target={@myself}
              class="btn btn-sm btn-primary"
            >
              Follow
            </button>
          <% end %>
        </li>
      </ul>
      <div :if={@has_more} id={"#{@id}-sentinel"} class="h-4"></div>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".InfiniteScroll">
        export default {
          mounted() {
            this.sentinel = this.el.querySelector(`#${this.el.id}-sentinel`)
            if (!this.sentinel) return
            this.observer = new IntersectionObserver(entries => {
              if (entries[0].isIntersecting) this.pushEvent("load_more", {})
            })
            this.observer.observe(this.sentinel)
          },
          updated() {
            const sentinel = this.el.querySelector(`#${this.el.id}-sentinel`)
            if (sentinel && sentinel !== this.sentinel) {
              if (this.sentinel) this.observer.unobserve(this.sentinel)
              this.sentinel = sentinel
              this.observer.observe(this.sentinel)
            } else if (!sentinel && this.observer) {
              this.observer.disconnect()
            }
          },
          destroyed() {
            if (this.observer) this.observer.disconnect()
          }
        }
      </script>
    </div>
    """
  end
end
