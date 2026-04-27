defmodule FramelensWeb.FeedLive do
  use FramelensWeb, :live_view

  alias Framelens.{FeedCache, PlatformStats, Subscriptions}
  alias Framelens.Jobs.SyncFeedJob

  @page_size 20

  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope && socket.assigns.current_scope.user.id

    followed = user_id && Subscriptions.followed_creators_for_user(user_id)

    if user_id && connected?(socket) do
      Phoenix.PubSub.subscribe(Framelens.PubSub, "feed:#{user_id}")

      Enum.each(followed, fn %{name: name} ->
        Phoenix.PubSub.subscribe(Framelens.PubSub, "creator:#{name}")
      end)
    end

    cond do
      is_list(followed) && followed == [] ->
        {:ok,
         assign(socket,
           all_posts: [],
           posts: [],
           has_more: false,
           syncing: false,
           pending_count: nil,
           user_id: user_id,
           suggested_creators: PlatformStats.most_followed()
         )}

      is_nil(user_id) ->
        {:ok,
         assign(socket,
           all_posts: [],
           posts: [],
           has_more: false,
           syncing: false,
           pending_count: nil,
           user_id: nil,
           suggested_creators: []
         )}

      true ->
        cached = FeedCache.get(user_id)

        {extra, syncing} =
          if is_nil(cached) do
            if connected?(socket), do: enqueue_sync(user_id)
            {paginate([], @page_size), true}
          else
            {paginate(cached, @page_size), false}
          end

        {:ok,
         socket
         |> assign(extra)
         |> assign(syncing: syncing, pending_count: nil, user_id: user_id, suggested_creators: [])}
    end
  end

  def handle_event("load_more", _params, %{assigns: %{has_more: false}} = socket) do
    {:noreply, socket}
  end

  def handle_event("load_more", _params, socket) do
    next_count = length(socket.assigns.posts) + @page_size
    posts = Enum.take(socket.assigns.all_posts, next_count)
    has_more = length(posts) < length(socket.assigns.all_posts)
    {:noreply, assign(socket, posts: posts, has_more: has_more)}
  end

  def handle_event("follow", %{"id" => creator_id}, socket) do
    Subscriptions.follow_creator(socket.assigns.user_id, String.to_integer(creator_id))

    all_posts = FeedCache.get(socket.assigns.user_id) || []
    enqueue_sync(socket.assigns.user_id)

    {:noreply,
     socket
     |> assign(paginate(all_posts, @page_size))
     |> assign(suggested_creators: [], syncing: true, pending_count: nil)}
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
    all_posts = FeedCache.get(socket.assigns.user_id) || []
    new_pending = max((socket.assigns.pending_count || 0) - 1, 0)
    page_count = max(length(socket.assigns.posts), @page_size)

    {:noreply,
     socket
     |> assign(paginate(all_posts, page_count))
     |> assign(syncing: new_pending > 0, pending_count: new_pending)}
  end

  defp paginate(all_posts, count) do
    posts = Enum.take(all_posts, count)
    %{all_posts: all_posts, posts: posts, has_more: length(posts) < length(all_posts)}
  end

  defp enqueue_sync(user_id) do
    %{"user_id" => user_id}
    |> SyncFeedJob.new()
    |> Oban.insert()
  end
end
