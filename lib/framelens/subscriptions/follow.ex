defmodule Framelens.Subscriptions.Follow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Framelens.Creators.Creator

  schema "follows" do
    field :user_id, :id

    belongs_to :creator, Creator
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(follow, attrs) do
    follow
    |> cast(attrs, [:user_id, :creator_id])
    |> validate_required([:user_id, :creator_id])
  end
end
