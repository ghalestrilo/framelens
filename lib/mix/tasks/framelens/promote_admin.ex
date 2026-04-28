defmodule Mix.Tasks.Framelens.PromoteAdmin do
  use Mix.Task

  @shortdoc "Promotes a user to admin by email"

  @impl Mix.Task
  def run([email]) do
    case Framelens.Accounts.get_user_by_email(email) do
      nil ->
        Mix.shell().error("No user found with email: #{email}")

      user ->
        user
        |> Ecto.Changeset.change(role: "admin")
        |> Framelens.Repo.update!()

        Mix.shell().info("#{email} promoted to admin")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix framelens.promote_admin <email>")
  end
end
