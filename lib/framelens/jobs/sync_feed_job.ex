defmodule Framelens.Jobs.SyncFeedJob do
  use Oban.Worker, queue: :feeds, max_attempts: 3

  alias Framelens.Subscriptions
  alias Framelens.Jobs.FetchCreatorFeedJob

  @module_to_key %{
    Framelens.Platform.YouTube   => "youtube",
    Framelens.Platform.Facebook  => "facebook",
    Framelens.Platform.Instagram => "instagram",
    Framelens.Platform.TikTok    => "tiktok",
    Framelens.Platform.Twitter   => "twitter"
  }

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    platforms = Subscriptions.platforms_for_user(user_id)
    platform_count = length(platforms)

    Phoenix.PubSub.broadcast(Framelens.PubSub, "feed:#{user_id}", {:sync_started, user_id, platform_count})

    Enum.each(platforms, fn platform ->
      %{
        "platform"    => Map.fetch!(@module_to_key, platform.__struct__),
        "platform_id" => platform.platform_id,
        "name"        => platform.name
      }
      |> FetchCreatorFeedJob.new()
      |> Oban.insert!()
    end)

    Process.sleep(1000)

    :ok
  end
end
