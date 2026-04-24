defmodule Framelens.Platform.Twitter do
  defstruct [:platform_id, :name]
end

defimpl Framelens.Platform, for: Framelens.Platform.Twitter do
  def fetch_content(%{platform_id: id, name: name}) do
    base = Application.fetch_env!(:framelens, :rsshub_url)
    url = "#{base}/twitter/user/#{id}"

    with {:ok, feed} <- ElixirRss.fetch_and_parse(url) do
      {:ok, Enum.map(feed.entries, &Map.put(&1, :author, name))}
    end
  end
end
