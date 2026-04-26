defmodule Framelens.Jobs.ScheduledSyncJob do
  use Oban.Worker, queue: :feeds, max_attempts: 1

  alias Framelens.Subscriptions
  alias Framelens.Jobs.FetchCreatorFeedJob
  alias Framelens.Platform.Registry

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Subscriptions.all_followed_creator_platforms()
    |> Enum.each(fn platform ->
      %{
        "platform"    => Registry.get_name(platform.__struct__),
        "platform_id" => platform.platform_id,
        "name"        => platform.name
      }
      |> FetchCreatorFeedJob.new()
      |> Oban.insert!()
    end)

    :ok
  end

end
