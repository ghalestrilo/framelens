defmodule Framelens.Scraper do
  alias Framelens.{FeedCache, Platform}

  def sync(platforms) do
    entries_by_creator =
      platforms
      |> Enum.map(fn platform ->
        case Platform.fetch_content(platform) do
          {:ok, entries} -> {platform.name, entries}
          _error -> {platform.name, []}
        end
      end)
      |> Map.new()

    FeedCache.put(entries_by_creator)

    entries_by_creator
    |> Map.values()
    |> List.flatten()
    |> Enum.sort_by(& &1.updated, {:desc, Date})
    |> Enum.slice(0, 20)
  end
end
