defmodule FramelensWeb.ErrorJSONTest do
  use FramelensWeb.ConnCase, async: true

  test "renders 404" do
    assert FramelensWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert FramelensWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
