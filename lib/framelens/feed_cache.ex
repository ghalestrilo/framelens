defmodule Framelens.FeedCache do
  @moduledoc """
  An Agent that holds fetched feed entries in memory, keyed by creator name.
  Feeds are stored globally and filtered per-user at read time based on their
  subscriptions, avoiding per-user duplication.

  State shape:
    %{creator_name => [entry, ...]}
  """

  use Agent

  alias Framelens.Subscriptions

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Returns a flat sorted list of entries for the given user by filtering the
  global cache down to their followed creators. Returns nil if none of their
  followed creators have been cached yet.
  """
  def get(user_id) do
    followed_names =
      Subscriptions.followed_creators_for_user(user_id)
      |> Enum.map(& &1.name)
      |> MapSet.new()

    cached = Agent.get(__MODULE__, &Map.filter(&1, fn {name, _} -> name in followed_names end))

    if map_size(cached) == 0 do
      nil
    else
      cached
      |> Map.values()
      |> List.flatten()
      |> Enum.sort_by(& &1.updated, {:desc, Date})
    end
  end

  @doc "Merges a map of %{creator_name => [entries]} into the global cache."
  def put(entries_by_creator) do
    Agent.update(__MODULE__, &Map.merge(&1, entries_by_creator))
  end

  @doc "Removes a creator's entries from the cache by name."
  def invalidate(creator_name) do
    Agent.update(__MODULE__, &Map.delete(&1, creator_name))
  end
end
