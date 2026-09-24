defmodule FramelensWeb.FeedLive do
  use FramelensWeb, :live_view

  import FramelensWeb.VideoPlayerComponent

  alias Framelens.{Accounts, FeedCache, PlatformStats, Subscriptions, QueueCache}
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

    assigns = base_assigns(user_id, followed)
    if assigns.syncing && connected?(socket), do: enqueue_sync(user_id)

    {:ok, assign(socket, assigns)}
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

  def handle_info({:feed_follow, creator_id}, socket) do
    Subscriptions.follow_creator(socket.assigns.user_id, creator_id)
    Task.start(fn -> PlatformStats.refresh() end)

    all_posts = FeedCache.get(socket.assigns.user_id) || []
    enqueue_sync(socket.assigns.user_id)

    {:noreply,
     socket
     |> assign(paginate(all_posts, @page_size))
     |> assign(suggested_creators: [], syncing: true, pending_count: nil, first_follow_flash: true)}
  end

  def handle_event("clear_first_follow_flash", _params, socket) do
    {:noreply, assign(socket, first_follow_flash: false)}
  end

  def handle_event("sync", _params, %{assigns: %{user_id: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("sync", _params, socket) do
    enqueue_sync(socket.assigns.user_id)
    {:noreply, assign(socket, syncing: true, pending_count: nil)}
  end

  def handle_event("add_to_queue", %{"url" => url}, socket) do
    post = Enum.find(socket.assigns.posts, &(&1.url == url))
    if post, do: QueueCache.add(socket.assigns.email, post)
    queue = QueueCache.get(socket.assigns.email)
    current = socket.assigns.current_video || List.first(queue)
    mode = if queue == [], do: :hidden, else: max_mode(socket.assigns.player_mode, :sidebar)

    {:noreply,
     socket
     |> put_flash(:info, "Added to queue")
     |> assign(queue: queue, current_video: current, player_mode: mode)}
  end

  def handle_event("play", %{"url" => url}, socket) do
    post = Enum.find(socket.assigns.queue, &(&1.url == url))
    {:noreply, assign(socket, current_video: post)}
  end

  def handle_event("remove_from_queue", %{"url" => url}, socket) do
    QueueCache.remove(socket.assigns.email, url)
    queue = QueueCache.get(socket.assigns.email)

    current =
      if socket.assigns.current_video && socket.assigns.current_video.url == url,
        do: List.first(queue),
        else: socket.assigns.current_video

    mode = if queue == [], do: :hidden, else: socket.assigns.player_mode
    {:noreply, assign(socket, queue: queue, current_video: current, player_mode: mode)}
  end

  def handle_event("next", _params, socket) do
    next =
      case socket.assigns.current_video do
        nil ->
          nil

        cur ->
          idx = Enum.find_index(socket.assigns.queue, &(&1.url == cur.url))
          Enum.at(socket.assigns.queue, (idx || 0) + 1)
      end

    {:noreply, assign(socket, current_video: next)}
  end

  def handle_event("expand_player", _params, socket) do
    {:noreply, assign(socket, player_mode: :fullscreen)}
  end

  def handle_event("collapse_player", _params, socket) do
    {:noreply, assign(socket, player_mode: :sidebar)}
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

  defp base_assigns(user_id, []) do
    %{
      all_posts: [],
      posts: [],
      has_more: false,
      syncing: false,
      pending_count: nil,
      user_id: user_id,
      email: nil,
      suggested_creators: Enum.take(PlatformStats.most_followed(), 5),
      first_follow_flash: false,
      queue: [],
      current_video: nil,
      player_mode: :hidden
    }
  end

  defp base_assigns(nil, _followed) do
    %{
      all_posts: [],
      posts: [],
      has_more: false,
      syncing: false,
      pending_count: nil,
      user_id: nil,
      email: nil,
      suggested_creators: [],
      first_follow_flash: false,
      queue: [],
      current_video: nil,
      player_mode: :hidden
    }
  end

  defp base_assigns(user_id, _followed) do
    user = Accounts.get_user!(user_id)
    email = user.email
    cached = FeedCache.get(user_id)
    queue = QueueCache.get(email)
    current_video = List.first(queue)
    player_mode = if queue == [], do: :hidden, else: :sidebar

    paginate(cached || [], @page_size)
    |> Map.merge(%{
      syncing: is_nil(cached),
      pending_count: nil,
      user_id: user_id,
      email: email,
      suggested_creators: [],
      first_follow_flash: false,
      queue: queue,
      current_video: current_video,
      player_mode: player_mode
    })
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

  defp max_mode(:fullscreen, _), do: :fullscreen
  defp max_mode(_, new), do: new
end
