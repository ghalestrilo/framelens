defmodule FramelensWeb.Admin.CreatorPlatformLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Oban.Job,
      repo: Framelens.Repo,
      update_changeset: &__MODULE__.changeset/3,
      create_changeset: &__MODULE__.changeset/3
    ]

  @impl Backpex.LiveResource
  def layout(_assigns), do: {FramelensWeb.Layouts, :admin}

  @impl Backpex.LiveResource
  def singular_name, do: "Job"

  @impl Backpex.LiveResource
  def plural_name, do: "Jobs"

  @impl Backpex.LiveResource
  def fields do
    []
  end

  def changeset(creator_platform, attrs, _metadata),
    do: Framelens.Creators.CreatorPlatform.changeset(creator_platform, attrs)
end
