defmodule Framelens.Subscriptions.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do

    field :user_id, :id
    field :creator_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [])
    |> validate_required([])
  end
end
