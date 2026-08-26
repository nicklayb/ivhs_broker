defmodule IvhsBroker.Repo do
  use Ecto.Repo,
    otp_app: :ivhs_broker,
    adapter: Ecto.Adapters.Postgres

  use Box.Ecto.RepoHelpers
end
