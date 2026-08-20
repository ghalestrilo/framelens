defmodule Framelens.QueueCache do
  @moduledoc """
  An Agent that holds per-user video queues in memory, keyed by email.
  Resets on server restart — no DB persistence.

  State shape:
    %{email => [post_map, ...]}
  """

  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc "Returns the queue for the given email, defaulting to []."
  def get(email) do
    Agent.get(__MODULE__, &Map.get(&1, email, []))
  end

  @doc "Appends post to the queue. Idempotent — duplicate urls are ignored."
  def add(email, post) do
    Agent.update(__MODULE__, fn state ->
      existing = Map.get(state, email, [])

      if Enum.any?(existing, &(&1.url == post.url)) do
        state
      else
        Map.put(state, email, existing ++ [post])
      end
    end)
  end

  @doc "Removes the post with the given url from the queue. No-op if not found."
  def remove(email, url) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, email, [], &Enum.reject(&1, fn p -> p.url == url end))
    end)
  end

  @doc "Clears the entire queue for the given email."
  def clear(email) do
    Agent.update(__MODULE__, &Map.delete(&1, email))
  end
end
