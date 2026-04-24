defmodule Framelens.Platform.Instagram do
  defstruct [:platform_id, :name]
end

defimpl Framelens.Platform, for: Framelens.Platform.Instagram do
  def fetch_content(%{platform_id: id, name: name}) do
    base = Application.fetch_env!(:framelens, :rsshub_url)
    url = "#{base}/picnob.info/user/#{id}"
    dbg(url)

    with {:ok, feed} <- ElixirRss.fetch_and_parse(url) do
      {:ok, Enum.map(feed.entries, &Map.put(&1, :author, name))}
    end
  end
end

# Req.get!("http://localhost:1200/picnob/user/")
