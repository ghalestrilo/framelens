defmodule Framelens.Scraper do
  alias Framelens.Subscriptions

  def sync(channels) do
    channels
    |> Enum.map(&Subscriptions.get_all_content/1)
    |> Enum.flat_map(fn
      {:ok, entries} -> entries
      _ -> []
    end)
    |> Enum.sort_by(& &1.updated, {:desc, Date})
    |> Enum.slice(0, 20)
  end
end
