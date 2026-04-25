defmodule FramelensWeb.FeedLive do
  use FramelensWeb, :live_view

  alias Framelens.{FeedCache, Subscriptions}
  alias Framelens.Jobs.SyncFeedJob

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope && socket.assigns.current_scope.user.id

    if user_id && connected?(socket) do
      Phoenix.PubSub.subscribe(Framelens.PubSub, "feed:#{user_id}")

      Subscriptions.followed_creators_for_user(user_id)
      |> Enum.each(fn %{name: name} ->
        Phoenix.PubSub.subscribe(Framelens.PubSub, "creator:#{name}")
      end)
    end

    case user_id && FeedCache.get(user_id) do
      nil when not is_nil(user_id) ->
        if connected?(socket), do: enqueue_sync(user_id)
        {:ok, assign(socket, videos: [], syncing: true, pending_count: nil, user_id: user_id)}

      videos when is_list(videos) ->
        {:ok, assign(socket, videos: videos, syncing: false, pending_count: nil, user_id: user_id)}

      _ ->
        {:ok, assign(socket, videos: [], syncing: false, pending_count: nil, user_id: nil)}
    end
  end

  def handle_event("sync", _params, %{assigns: %{user_id: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("sync", _params, socket) do
    enqueue_sync(socket.assigns.user_id)
    {:noreply, assign(socket, syncing: true, pending_count: nil)}
  end

  def handle_info({:sync_started, _user_id, 0}, socket) do
    {:noreply, assign(socket, syncing: false, pending_count: 0)}
  end

  def handle_info({:sync_started, _user_id, count}, socket) do
    {:noreply, assign(socket, pending_count: count)}
  end

  def handle_info({:creator_fetched, _name}, socket) do
    videos = FeedCache.get(socket.assigns.user_id) || []
    new_pending = max((socket.assigns.pending_count || 0) - 1, 0)
    {:noreply, assign(socket, videos: videos, syncing: new_pending > 0, pending_count: new_pending)}
  end

  defp enqueue_sync(user_id) do
    %{"user_id" => user_id}
    |> SyncFeedJob.new()
    |> Oban.insert()
  end
end
