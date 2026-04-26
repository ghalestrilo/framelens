defmodule Framelens.Jobs.FetchCreatorFeedJob do
  use Oban.Worker, queue: :feeds, max_attempts: 5

  require Logger
  alias Framelens.{FeedCache, Platform}
  alias Framelens.Platform.Registry

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"platform" => platform_key, "platform_id" => platform_id, "name" => name}
      }) do
    mod = Registry.get_module(platform_key)
    platform = struct(mod, platform_id: platform_id, name: name)

    case Platform.fetch_content(platform) do
      {:ok, entries} ->
        Logger.info(entries)
        FeedCache.put(%{name => entries})
        Phoenix.PubSub.broadcast(Framelens.PubSub, "creator:#{name}", {:creator_fetched, name})
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
