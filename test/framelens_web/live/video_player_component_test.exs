defmodule FramelensWeb.VideoPlayerComponentTest do
  use FramelensWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import FramelensWeb.VideoPlayerComponent

  test "watch?v=ID URL renders iframe with embed src" do
    html = render_component(&video_player/1, video_url: "https://www.youtube.com/watch?v=abc123", title: "Test")
    assert html =~ ~s(src="https://www.youtube.com/embed/abc123")
    assert html =~ "<iframe"
  end

  test "youtu.be/ID URL renders iframe with embed src" do
    html = render_component(&video_player/1, video_url: "https://youtu.be/xyz789", title: "Test")
    assert html =~ ~s(src="https://www.youtube.com/embed/xyz789")
  end

  test "extra query params only extract the v value" do
    html = render_component(&video_player/1, video_url: "https://www.youtube.com/watch?v=abc123&t=30s", title: "Test")
    assert html =~ ~s(src="https://www.youtube.com/embed/abc123")
    refute html =~ "t=30s"
  end

  test "nil url renders placeholder, no iframe" do
    html = render_component(&video_player/1, video_url: nil, title: "Test")
    refute html =~ "<iframe"
    assert html =~ "<div"
  end

  test "non-youtube url renders placeholder, no iframe" do
    html = render_component(&video_player/1, video_url: "https://www.facebook.com/video/123", title: "Test")
    refute html =~ "<iframe"
    assert html =~ "<div"
  end

  test "iframe has allowfullscreen and title attribute" do
    html = render_component(&video_player/1, video_url: "https://youtu.be/abc123", title: "My Video")
    assert html =~ "allowfullscreen"
    assert html =~ ~s(title="My Video")
  end
end
