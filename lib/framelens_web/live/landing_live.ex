defmodule FramelensWeb.LandingLive do
  use FramelensWeb, :live_view

  @roadmap [
    {"📡", "More platforms", "Support for media platforms beyond YouTube — facebook, instagram, tiktok, podcasts, newsletters, blogs, and more."},
    {"🗂️", "Better creator management", "More robust management of creator data, to improve completeness and prevent misappropriation."},
    {"🔍", "Better feed discovery", "Filtering, ordering, and smarter ways to find and prioritize your content."},
    {"🌐", "Public & curated feeds", "Create multiple feeds, share them or discover feeds curated by others."},
    {"✨", "More to come", "You will know it when we get there"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, roadmap: @roadmap)}
  end
end
