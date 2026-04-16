defmodule Framelens.Platform.YouTube do
  defstruct [:platform_id, :name]
end

defimpl Framelens.Platform, for: Framelens.Platform.YouTube do
  def fetch_content(%{platform_id: id, name: name}) do
    url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{id}"

    with {:ok, feed} <- dbg(ElixirRss.fetch_and_parse(url)) do
      {:ok, Enum.map(feed.entries, &Map.put(&1, :author, name))}
    end
  end
end
