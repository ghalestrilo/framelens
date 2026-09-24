defmodule FramelensWeb.FeedLiveQueueTest do
  use FramelensWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Framelens.AccountsFixtures

  alias Framelens.{FeedCache, QueueCache}
  alias Framelens.Creators

  @post %{
    url: "https://www.youtube.com/watch?v=abc123",
    youtube: "https://www.youtube.com/watch?v=abc123",
    title: "Test Video",
    author: "test_creator",
    updated: ~U[2024-01-01 00:00:00Z]
  }

  @post2 %{
    url: "https://www.youtube.com/watch?v=def456",
    youtube: "https://www.youtube.com/watch?v=def456",
    title: "Second Video",
    author: "test_creator",
    updated: ~U[2024-01-02 00:00:00Z]
  }

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)

    {:ok, creator} = Creators.create_creator(%{name: "test_creator", user_id: user.id})
    Framelens.Subscriptions.follow_creator(user.id, creator.id)
    FeedCache.put(%{"test_creator" => [@post, @post2]})

    on_exit(fn ->
      QueueCache.clear(user.email)
      FeedCache.invalidate("test_creator")
    end)

    %{conn: conn, user: user}
  end

  # ── Original 5 tests ──────────────────────────────────────────────────────

  test "feed table renders a Queue column header", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/feed")
    assert html =~ "Queue"
  end

  test "each row has an add_to_queue button", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/feed")
    assert html =~ ~s(phx-click="add_to_queue")
  end

  test "clicking + adds post to queue", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    view |> element("button[phx-click='add_to_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert QueueCache.get(user.email) != []
    assert hd(QueueCache.get(user.email)).url == @post.url
  end

  test "clicking + shows a flash message", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='add_to_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert html =~ "Added to queue"
  end

  test "clicking + twice does not duplicate the post", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    view |> element("button[phx-click='add_to_queue'][phx-value-url='#{@post.url}']") |> render_click()
    view |> element("button[phx-click='add_to_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert length(QueueCache.get(user.email)) == 1
  end

  # ── Sidebar appearance ────────────────────────────────────────────────────

  test "empty queue renders no queue-sidebar element", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/feed")
    refute html =~ "queue-sidebar"
  end

  test "after adding a video, queue-sidebar element appears", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='add_to_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert html =~ "queue-sidebar"
  end

  test "feed table is still visible alongside the sidebar", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='add_to_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert html =~ "queue-sidebar"
    assert html =~ ~s(phx-click="add_to_queue")
  end

  # ── Player controls ───────────────────────────────────────────────────────

  test "sidebar shows a play button for queued posts", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    QueueCache.add(user.email, @post2)
    {:ok, _view, html} = live(conn, ~p"/feed")
    assert html =~ ~s(phx-click="play")
  end

  test "clicking play sets the iframe to that video's embed URL", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    QueueCache.add(user.email, @post2)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='play'][phx-value-url='#{@post2.url}']") |> render_click()
    assert html =~ "embed/def456"
  end

  test "sidebar shows a next button", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, _view, html} = live(conn, ~p"/feed")
    assert html =~ ~s(phx-click="next")
  end

  test "clicking next advances current_video to the second post", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    QueueCache.add(user.email, @post2)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='next']") |> render_click()
    assert html =~ "embed/def456"
  end

  test "clicking next on the last item removes the iframe", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='next']") |> render_click()
    refute html =~ "<iframe"
  end

  test "clicking remove_from_queue removes the post from the list", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='remove_from_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert QueueCache.get(user.email) == []
    refute html =~ "queue-sidebar"
  end

  test "removing current video auto-advances to next", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    QueueCache.add(user.email, @post2)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='remove_from_queue'][phx-value-url='#{@post.url}']") |> render_click()
    assert html =~ "embed/def456"
  end

  # ── Mode toggle ───────────────────────────────────────────────────────────

  test "sidebar shows an expand_player button", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, _view, html} = live(conn, ~p"/feed")
    assert html =~ ~s(phx-click="expand_player")
  end

  test "clicking expand_player renders player-fullscreen element", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='expand_player']") |> render_click()
    assert html =~ "player-fullscreen"
  end

  test "fullscreen mode shows a collapse_player button", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, view, _html} = live(conn, ~p"/feed")
    view |> element("button[phx-click='expand_player']") |> render_click()
    html = render(view)
    assert html =~ ~s(phx-click="collapse_player")
  end

  test "clicking collapse_player returns to sidebar mode", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, view, _html} = live(conn, ~p"/feed")
    view |> element("button[phx-click='expand_player']") |> render_click()
    html = view |> element("button[phx-click='collapse_player']") |> render_click()
    refute html =~ "player-fullscreen"
    assert html =~ "queue-sidebar"
  end

  test "fullscreen mode renders the feed table below the queue", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post)
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='expand_player']") |> render_click()
    assert html =~ "player-fullscreen"
    assert html =~ ~s(phx-click="add_to_queue")
  end
end
