defmodule Framelens.Creators.Creator do
  use Ecto.Schema
  import Ecto.Changeset

  alias Framelens.Creators.CreatorPlatform

  schema "creators" do
    field :name, :string
    field :bio, :string
    field :user_id, :id

    has_many :platforms, CreatorPlatform

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(creator, attrs) do
    creator
    |> cast(attrs, [:name, :bio])
    |> validate_required([:name])
  end

  def changeset_with_platforms(creator, attrs) do
    creator
    |> cast(attrs, [:name, :bio])
    |> validate_required([:name])
    |> cast_assoc(:platforms, with: &CreatorPlatform.changeset/2, required: true)
  end
end
