defmodule Framelens.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :user_id, references(:users, on_delete: :nothing)
      add :creator_id, references(:creators, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:follows, [:user_id])
    create index(:follows, [:creator_id])
    create unique_index(:follows, [:user_id, :creator_id])
  end
end
