defmodule Framelens.Repo do
  use Ecto.Repo,
    otp_app: :framelens,
    adapter: Ecto.Adapters.Postgres
end
