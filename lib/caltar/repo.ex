defmodule Caltar.Repo do
  use Ecto.Repo,
    otp_app: :caltar,
    adapter: Ecto.Adapters.Postgres

  use Box.Ecto.RepoHelpers
end
