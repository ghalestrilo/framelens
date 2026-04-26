defmodule FramelensWeb.Admin.CreatorLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Framelens.Creators.Creator,
      repo: Framelens.Repo,
      update_changeset: &__MODULE__.changeset/3,
      create_changeset: &__MODULE__.changeset/3
    ]

  @impl Backpex.LiveResource
  def layout(_assigns), do: {FramelensWeb.Layouts, :admin}

  @impl Backpex.LiveResource
  def singular_name, do: "Creator"

  @impl Backpex.LiveResource
  def plural_name, do: "Creators"

  @impl Backpex.LiveResource
  def fields do
    import Ecto.Query

    [
      name: %{
        module: Backpex.Fields.Text,
        label: "Name"
      },
      bio: %{
        module: Backpex.Fields.Text,
        label: "Bio"
      },
      platforms: %{
        module: Backpex.Fields.InlineCRUD,
        label: "Platforms",
        type: :assoc,
        child_fields: [
          platform: %{
            module: Backpex.Fields.Text,
            label: "Platform"
          },
          platform_id: %{
            module: Backpex.Fields.Text,
            label: "Platform ID"
          }
        ]
      }
    ]
  end

  def changeset(creator, attrs, _metadata),
    do: Framelens.Creators.Creator.changeset(creator, attrs)
end
