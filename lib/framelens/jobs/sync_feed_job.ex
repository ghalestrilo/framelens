defmodule Framelens.Jobs.SyncFeedJob do
  use Oban.Worker, queue: :feeds, max_attempts: 3

  alias Framelens.Subscriptions
  alias Framelens.Jobs.FetchCreatorFeedJob
  alias Framelens.Platform.Registry

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    platforms = Subscriptions.platforms_for_user(user_id)
    platform_count = length(platforms)

    Phoenix.PubSub.broadcast(Framelens.PubSub, "feed:#{user_id}", {:sync_started, user_id, platform_count})

    Enum.each(platforms, fn platform ->
      %{
        "platform"    => Registry.get_name(platform.__struct__),
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
