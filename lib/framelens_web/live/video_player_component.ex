defmodule FramelensWeb.VideoPlayerComponent do
  use FramelensWeb, :html

  attr :video_url, :string, default: nil
  attr :title, :string, default: "Video"

  def video_player(assigns) do
    assigns = assign(assigns, :video_id, extract_youtube_id(assigns.video_url))

    ~H"""
    <%= if @video_id do %>
      <iframe
        src={"https://www.youtube.com/embed/#{@video_id}"}
        title={@title}
        class="w-full aspect-video rounded-lg"
        allowfullscreen
        frameborder="0"
      ></iframe>
    <% else %>
      <div class="w-full aspect-video bg-base-300 rounded-lg flex items-center justify-center text-base-content/40">
        No video selected
      </div>
    <% end %>
    """
  end

  defp extract_youtube_id(nil), do: nil

  defp extract_youtube_id(url) do
    cond do
      m = Regex.run(~r/youtube\.com\/watch\?.*v=([A-Za-z0-9_-]+)/, url) -> List.last(m)
      m = Regex.run(~r/youtu\.be\/([A-Za-z0-9_-]+)/, url) -> List.last(m)
      true -> nil
    end
  end
end
