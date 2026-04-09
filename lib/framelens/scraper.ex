defmodule Framelens.Scraper do
  alias Framelens.Subscriptions

  @channels [
    %{youtube_id: "UC--VosYH0BHISbb4SFO9rQA", name: "Zheanna Erose"},
    %{youtube_id: "UC-2LWDrIxHOd2mnt1RHbzrg", name: "Olivia Jack"},
    %{youtube_id: "UC-8QAzbLcRglXeN_MY9blyw", name: "Ben Awad"},
    %{youtube_id: "UC-8Uff7i2h5qtIvjXJDJqYA", name: "Minhas Plantas"},
    %{youtube_id: "UC-ZX7WqyBL9k1OO7jCtIZQA", name: "쿄쿄쿜"}
  ]

  def sync do
    @channels
    |> Enum.map(&Subscriptions.get_all_content/1)
    |> Enum.flat_map(fn
      {:ok, entries} -> entries
      _ -> []
    end)
    |> Enum.sort_by(& &1.updated)
    |> Enum.slice(0, 10)
  end
end
