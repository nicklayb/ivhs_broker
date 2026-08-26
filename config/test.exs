import Config

config :ivhs_broker, IvhsBroker.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :ivhs_broker, IvhsBrokerWeb.Endpoint, server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
