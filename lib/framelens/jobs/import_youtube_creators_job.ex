defmodule Framelens.Jobs.ImportYouTubeCreatorsJob do
  use Oban.Worker, queue: :feeds, max_attempts: 3

  require Logger
  alias Framelens.{Creators, YouTube}

  # Broad search terms run once per day to discover popular channels.
  @queries ~w(
    technology programming
    science education
    cooking food
    music
    gaming
    documentary
    comedy
    fitness health
    finance investing
    politics
  )

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Enum.each(@queries, fn query ->
      case YouTube.search_channels(query) do
        {:ok, channels} ->
          Enum.each(channels, fn %{name: name, channel_id: channel_id} ->
            Creators.import_youtube_creator(name, channel_id)
          end)

          Logger.info("ImportYouTubeCreatorsJob: imported #{length(channels)} channels for \"#{query}\"")

        {:error, reason} ->
          Logger.warning("ImportYouTubeCreatorsJob: failed for \"#{query}\": #{inspect(reason)}")
      end
    end)

    Framelens.PlatformStats.refresh()
    :ok
  end
end
