defmodule FramelensWeb.PageController do
  use FramelensWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
