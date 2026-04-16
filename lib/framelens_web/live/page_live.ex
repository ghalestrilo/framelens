defmodule FramelensWeb.PageLive do
  use FramelensWeb, :live_view

  alias Framelens.{FeedCache, Scraper, Subscriptions}

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    case FeedCache.get(user_id) do
      nil ->
        send(self(), :do_sync)
        {:ok, assign(socket, videos: [], syncing: true, user_id: user_id)}

      videos ->
        {:ok, assign(socket, videos: videos, syncing: false, user_id: user_id)}
    end
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
