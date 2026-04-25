defmodule Framelens.Jobs.ScheduledSyncJob do
  use Oban.Worker, queue: :feeds, max_attempts: 1

  alias Framelens.Subscriptions
  alias Framelens.Jobs.FetchCreatorFeedJob

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Subscriptions.all_followed_creator_platforms()
    |> Enum.each(fn platform ->
      %{
        "platform"    => platform_key(platform.__struct__),
        "platform_id" => platform.platform_id,
        "name"        => platform.name
      }
      |> FetchCreatorFeedJob.new()
      |> Oban.insert!()
    end)

    :ok
  end

  @module_to_key %{
    Framelens.Platform.YouTube   => "youtube",
    Framelens.Platform.Facebook  => "facebook",
    Framelens.Platform.Instagram => "instagram",
    Framelens.Platform.TikTok    => "tiktok",
    Framelens.Platform.Twitter   => "twitter"
  }

  defp platform_key(mod), do: Map.fetch!(@module_to_key, mod)
end
