defmodule FramelensWeb.FeedLive do
  use FramelensWeb, :live_view

  alias Framelens.{FeedCache, Scraper, Subscriptions}

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope && socket.assigns.current_scope.user.id

    case user_id && FeedCache.get(user_id) do
      nil when not is_nil(user_id) ->
        send(self(), :do_sync)
        {:ok, assign(socket, videos: [], syncing: true, user_id: user_id)}

      videos when is_list(videos) ->
        {:ok, assign(socket, videos: videos, syncing: false, user_id: user_id)}

      _ ->
        # anonymous user or no cache
        {:ok, assign(socket, videos: [], syncing: false, user_id: nil)}
    end
  end

  def handle_event("sync", _params, %{assigns: %{user_id: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("sync", _params, socket) do
    send(self(), :do_sync)
    {:noreply, assign(socket, syncing: true)}
  end

  def handle_info(:do_sync, socket) do
    user_id = socket.assigns.user_id
    channels = Subscriptions.platforms_for_user(user_id)
    videos = Scraper.sync(channels)
    {:noreply, assign(socket, videos: videos, syncing: false)}
  end
end
