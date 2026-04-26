defmodule Framelens.Platform.Facebook do
  defstruct [:platform_id, :name]
end

defimpl Framelens.Platform, for: Framelens.Platform.Facebook do
  def fetch_content(%{platform_id: id, name: name}) do
    base = Application.fetch_env!(:framelens, :rsshub_url)
    url = "#{base}/facebook/page/#{id}"

    dbg(url)

    with {:ok, feed} <- ElixirRss.fetch_and_parse(url) do
      {:ok, Enum.map(feed.entries, &Map.put(&1, :author, name))}
    else
      error -> dbg(error)
    end
  end
end
