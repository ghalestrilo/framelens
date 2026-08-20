defmodule FramelensWeb.QueueLive do
  use FramelensWeb, :live_view

  alias Framelens.QueueCache
  import FramelensWeb.VideoPlayerComponent

  def mount(_params, _session, socket) do
    email = socket.assigns.current_scope.user.email
    queue = QueueCache.get(email)

    {:ok,
     assign(socket,
       email: email,
       queue: queue,
       current_video: List.first(queue),
       mode: :fullscreen
     )}
  end

  def handle_event("play", %{"url" => url}, socket) do
    post = Enum.find(socket.assigns.queue, &(&1.url == url))
    {:noreply, assign(socket, current_video: post)}
  end

  def handle_event("remove_from_queue", %{"url" => url}, socket) do
    QueueCache.remove(socket.assigns.email, url)
    queue = QueueCache.get(socket.assigns.email)

    current =
      if socket.assigns.current_video && socket.assigns.current_video.url == url do
        List.first(queue)
      else
        socket.assigns.current_video
      end

    {:noreply, assign(socket, queue: queue, current_video: current)}
  end

  def handle_event("next", _params, socket) do
    next =
      case socket.assigns.current_video do
        nil ->
          nil

        current ->
          idx = Enum.find_index(socket.assigns.queue, &(&1.url == current.url))
          Enum.at(socket.assigns.queue, (idx || 0) + 1)
      end

    {:noreply, assign(socket, current_video: next)}
  end

  def handle_event("toggle_mode", _params, socket) do
    mode = if socket.assigns.mode == :fullscreen, do: :sidebar, else: :fullscreen
    {:noreply, assign(socket, mode: mode)}
  end
end
