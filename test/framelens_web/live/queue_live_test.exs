defmodule FramelensWeb.QueueLiveTest do
  use FramelensWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Framelens.AccountsFixtures

  alias Framelens.QueueCache

  @post1 %{
    url: "https://www.youtube.com/watch?v=aaa111",
    youtube: "https://www.youtube.com/watch?v=aaa111",
    title: "First Video",
    author: "Creator A",
    updated: ~U[2024-01-01 00:00:00Z]
  }
  @post2 %{
    url: "https://www.youtube.com/watch?v=bbb222",
    youtube: "https://www.youtube.com/watch?v=bbb222",
    title: "Second Video",
    author: "Creator B",
    updated: ~U[2024-01-02 00:00:00Z]
  }

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)

    on_exit(fn -> QueueCache.clear(user.email) end)

    %{conn: conn, user: user}
  end

  test "unauthenticated visit redirects to login", %{conn: conn} do
    conn = Phoenix.ConnTest.build_conn()
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/queue")
  end

  test "authenticated mount renders Queue heading", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/queue")
    assert html =~ "Queue"
  end

  test "empty queue shows placeholder", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/queue")
    assert html =~ "Your queue is empty"
  end

  test "posts in queue have their titles visible", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    QueueCache.add(user.email, @post2)
    {:ok, _view, html} = live(conn, ~p"/queue")
    assert html =~ "First Video"
    assert html =~ "Second Video"
  end

  test "first queued post is the current video", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    QueueCache.add(user.email, @post2)
    {:ok, _view, html} = live(conn, ~p"/queue")
    assert html =~ ~s(embed/aaa111)
  end

  test "clicking Remove removes the post from the list", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    {:ok, view, _html} = live(conn, ~p"/queue")
    html = view |> element("button[phx-click='remove_from_queue']") |> render_click()
    refute html =~ "First Video"
  end

  test "clicking Play sets the post as current_video", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    QueueCache.add(user.email, @post2)
    {:ok, view, _html} = live(conn, ~p"/queue")
    # Play the second video
    html = view |> element("button[phx-click='play'][phx-value-url='#{@post2.url}']") |> render_click()
    assert html =~ ~s(embed/bbb222)
  end

  test "removing current video advances to next", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    QueueCache.add(user.email, @post2)
    {:ok, view, _html} = live(conn, ~p"/queue")
    # Remove the first (currently playing) video
    html = view |> element("button[phx-click='remove_from_queue'][phx-value-url='#{@post1.url}']") |> render_click()
    assert html =~ ~s(embed/bbb222)
  end

  test "clicking Next advances current_video", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    QueueCache.add(user.email, @post2)
    {:ok, view, _html} = live(conn, ~p"/queue")
    html = view |> element("button[phx-click='next']") |> render_click()
    assert html =~ ~s(embed/bbb222)
  end

  test "clicking Next on last item sets current_video to nil", %{conn: conn, user: user} do
    QueueCache.add(user.email, @post1)
    {:ok, view, _html} = live(conn, ~p"/queue")
    html = view |> element("button[phx-click='next']") |> render_click()
    refute html =~ "<iframe"
  end

  test "default mode is fullscreen (no sidebar-mode class)", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/queue")
    refute html =~ "sidebar-mode"
  end

  test "clicking Sidebar mode adds sidebar-mode class", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/queue")
    html = view |> element("button[phx-click='toggle_mode']") |> render_click()
    assert html =~ "sidebar-mode"
  end

  test "clicking Fullscreen mode removes sidebar-mode class", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/queue")
    view |> element("button[phx-click='toggle_mode']") |> render_click()
    html = view |> element("button[phx-click='toggle_mode']") |> render_click()
    refute html =~ "sidebar-mode"
  end
end
