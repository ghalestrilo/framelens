defmodule Framelens.Creators.Creator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "creators" do
    field :name, :string
    field :bio, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(creator, attrs) do
    creator
    |> cast(attrs, [:name, :bio])
    |> validate_required([:name])
  end
end
