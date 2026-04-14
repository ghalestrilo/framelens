defmodule Framelens.Repo.Migrations.CreateCreatorPlatforms do
  use Ecto.Migration

  def change do
    create table(:creator_platforms) do
      add :platform, :string
      add :platform_id, :string
      add :creator_id, references(:creators, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:creator_platforms, [:creator_id])
    create unique_index(:creator_platforms, [:platform, :platform_id])
    create unique_index(:creator_platforms, [:creator_id, :platform])
  end
end
