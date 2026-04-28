defmodule Framelens.Repo.Migrations.UpdateCreatorPlatformsOnDelete do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE creator_platforms DROP CONSTRAINT creator_platforms_creator_id_fkey"
    execute "ALTER TABLE creator_platforms ADD CONSTRAINT creator_platforms_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE CASCADE"
  end

  def down do
    execute "ALTER TABLE creator_platforms DROP CONSTRAINT creator_platforms_creator_id_fkey"
    execute "ALTER TABLE creator_platforms ADD CONSTRAINT creator_platforms_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creators(id) ON DELETE NO ACTION"
  end
end
