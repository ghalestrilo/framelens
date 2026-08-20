defmodule Framelens.Platform.YouTube do
  defstruct [:platform_id, :name]
end

defimpl Framelens.Platform, for: Framelens.Platform.YouTube do
  # Main scenario: using @ for platform IDs.
  def fetch_content(%{platform_id: "@" <> id, name: name}) do
    base = Application.fetch_env!(:framelens, :rsshub_url)
    url = "#{base}/youtube/user/@#{URI.encode(id)}"

    with {:ok, %{status: 200, body: xml}} <- Req.get(url),
         stripped <-
           Regex.replace(
             ~r/(<item>.*?)<description>.*?<\/description>(.*?<\/item>)/s,
             xml,
             "\\1<description>.</description>\\2",
             global: true
           ),
         {:ok, feed} <- ElixirRss.parse(stripped, url) do
      {:ok, Enum.map(feed.entries, &Map.put(&1, :author, name))}
    else
      {:ok, %{status: status}} -> {:error, "HTTP #{status} fetching #{url}"}
      {:error, reason} -> {:error, reason}
    end
  end

  # Legacy: support Youtube IDs for backwards-compatibility
  # (and as a fallback in case we can't scale with API keys)
  def fetch_content(%{platform_id: id, name: name}) do
    url = "https://www.youtube.com/feeds/videos.xml?channel_id=#{id}"
    # base = Application.fetch_env!(:framelens, :rsshub_url)
    # url = "#{base}/youtube/user/#{id}"

    with {:ok, feed} <- ElixirRss.fetch_and_parse(url) do
      {:ok, Enum.map(feed.entries, &Map.put(&1, :author, name))}
    end
  end
end
