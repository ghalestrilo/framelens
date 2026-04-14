defmodule Framelens.Repo.Migrations.CreateCreators do
  use Ecto.Migration

  def change do
    create table(:creators) do
      add :name, :string
      add :bio, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:creators, [:user_id])
  end
end
