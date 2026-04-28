defmodule Mix.Tasks.Framelens.ImportYoutubeCreators do
  use Mix.Task

  @shortdoc "Imports popular YouTube creators into the database"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")
    Framelens.Jobs.ImportYouTubeCreatorsJob.perform(%Oban.Job{args: %{}})
  end
end
