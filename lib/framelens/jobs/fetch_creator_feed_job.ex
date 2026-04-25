defmodule Framelens.Jobs.FetchCreatorFeedJob do
  use Oban.Worker, queue: :feeds, max_attempts: 5

  alias Framelens.{FeedCache, Platform}

  @platform_modules %{
    "youtube"   => Framelens.Platform.YouTube,
    "facebook"  => Framelens.Platform.Facebook,
    "instagram" => Framelens.Platform.Instagram,
    "tiktok"    => Framelens.Platform.TikTok,
    "twitter"   => Framelens.Platform.Twitter
  }

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"platform" => platform_key, "platform_id" => platform_id, "name" => name}}) do
    mod = Map.fetch!(@platform_modules, platform_key)
    platform = struct(mod, platform_id: platform_id, name: name)

    case Platform.fetch_content(platform) do
      {:ok, entries} ->
        FeedCache.put(%{name => entries})
        Phoenix.PubSub.broadcast(Framelens.PubSub, "creator:#{name}", {:creator_fetched, name})
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
