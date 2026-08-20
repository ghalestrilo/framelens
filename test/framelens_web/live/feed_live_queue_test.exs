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

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)

    # Create a creator and follow it so FeedCache.get/1 returns the seeded posts
    {:ok, creator} = Creators.create_creator(%{name: "test_creator", user_id: user.id})
    Framelens.Subscriptions.follow_creator(user.id, creator.id)
    FeedCache.put(%{"test_creator" => [@post]})

    on_exit(fn ->
      QueueCache.clear(user.email)
      FeedCache.invalidate("test_creator")
    end)

    %{conn: conn, user: user}
  end

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
    view |> element("button[phx-click='add_to_queue']") |> render_click()
    assert QueueCache.get(user.email) != []
    assert hd(QueueCache.get(user.email)).url == @post.url
  end

  test "clicking + shows a flash message", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    html = view |> element("button[phx-click='add_to_queue']") |> render_click()
    assert html =~ "Added to queue"
  end

  test "clicking + twice does not duplicate the post", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/feed")
    view |> element("button[phx-click='add_to_queue']") |> render_click()
    view |> element("button[phx-click='add_to_queue']") |> render_click()
    assert length(QueueCache.get(user.email)) == 1
  end
end
