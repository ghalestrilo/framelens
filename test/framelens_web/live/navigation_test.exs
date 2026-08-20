defmodule FramelensWeb.NavigationTest do
  use FramelensWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Framelens.AccountsFixtures

  test "logged-in user sees Queue nav link", %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    {:ok, _view, html} = live(conn, ~p"/feed")
    assert html =~ ~s(href="/queue")
    assert html =~ "Queue"
  end

  test "logged-out user does not see Queue nav link", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    refute html =~ ~s(href="/queue")
  end
end
