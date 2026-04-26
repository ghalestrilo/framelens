defmodule Framelens.Creators.CreatorPlatform do
  use Ecto.Schema
  import Ecto.Changeset

  schema "creator_platforms" do
    field :platform, :string
    field :platform_id, :string

    belongs_to :creator, Framelens.Creators.Creator

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(creator_platform, attrs) do
    creator_platform
    |> cast(attrs, [:platform, :platform_id])
    |> validate_required([:platform, :platform_id])
  end
end
