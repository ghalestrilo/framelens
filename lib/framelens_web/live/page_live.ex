defmodule FramelensWeb.PageLive do
  use FramelensWeb, :live_view

  alias Framelens.{Scraper, Subscriptions}

  def mount(_params, _session, socket) do
    send(self(), :do_sync)
    {:ok, assign(socket, videos: [], syncing: true)}
  end

  def handle_event("sync", _params, socket) do
    send(self(), :do_sync)
    {:noreply, assign(socket, syncing: true)}
  end

  def handle_info(:do_sync, socket) do
    user_id = socket.assigns.current_scope.user.id
    channels = Subscriptions.platforms_for_user(user_id)
    videos = Scraper.sync(channels)
    {:noreply, assign(socket, videos: videos, syncing: false)}
  end
end
