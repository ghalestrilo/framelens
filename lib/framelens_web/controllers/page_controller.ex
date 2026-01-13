defmodule FramelensWeb.PageController do
  use FramelensWeb, :controller

  def home(conn, _params) do
    videos = [
      %{
        title: "How to Build a Phoenix App",
        author_handle: "@elixir_dev",
        youtube: "https://youtube.com/watch?v=abc123",
        facebook: "https://facebook.com/video/123456",
        tiktok: "https://tiktok.com/@user/video/789012",
        instagram: "https://instagram.com/p/abc123"
      },
      %{
        title: "Elixir GenServers Explained",
        author_handle: "@functional_programmer",
        youtube: "https://youtube.com/watch?v=def456",
        facebook: nil,
        tiktok: "https://tiktok.com/@user/video/345678",
        instagram: "https://instagram.com/p/def456"
      },
      %{
        title: "Phoenix LiveView Tutorial",
        author_handle: "@realtime_web",
        youtube: "https://youtube.com/watch?v=ghi789",
        facebook: "https://facebook.com/video/789012",
        tiktok: "https://tiktok.com/@user/video/901234",
        instagram: nil
      },
      %{
        title: "Building Scalable Apps with OTP",
        author_handle: "@elixir_dev",
        youtube: "https://youtube.com/watch?v=jkl012",
        facebook: "https://facebook.com/video/345678",
        tiktok: nil,
        instagram: "https://instagram.com/p/jkl012"
      },
      %{
        title: "Ecto Query Deep Dive",
        author_handle: "@database_guru",
        youtube: nil,
        facebook: "https://facebook.com/video/901234",
        tiktok: "https://tiktok.com/@user/video/567890",
        instagram: "https://instagram.com/p/mno345"
      }
    ]

    render(conn, :home, videos: videos)
  end
end
