defmodule Framelens.PlatformStats do
  @moduledoc """
  Agent that caches platform-wide statistics to avoid repeated DB queries.

  State shape:
    %{most_followed: [%{id, name, follow_count}]}
  """

  use Agent

  import Ecto.Query
  alias Framelens.{Repo, Creators.Creator, Subscriptions.Follow}

  @limit 100

  def start_link(_opts) do
    Agent.start_link(fn -> compute() end, name: __MODULE__)
  end

  @doc "Returns up to #{@limit} creators ordered by follow count descending."
  def most_followed do
    Agent.get(__MODULE__, & &1.most_followed)
  end

  @doc "Recomputes stats from the DB. Call after follow/unfollow events."
  def refresh do
    Agent.update(__MODULE__, fn _ -> compute() end)
  end

  defp compute do
    most_followed =
      Repo.all(
        from c in Creator,
          join: f in Follow,
          on: f.creator_id == c.id,
          group_by: [c.id, c.name],
          order_by: [desc: count(f.id)],
          limit: @limit,
          select: %{id: c.id, name: c.name, follow_count: count(f.id)}
      )

    %{most_followed: most_followed}
  end
end
