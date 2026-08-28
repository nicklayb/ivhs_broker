import Config

config :ivhs_broker,
  environment: config_env(),
  ecto_repos: [IvhsBroker.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :ivhs_broker, IvhsBroker.Repo, migration_timestamps: [type: :utc_datetime_usec]

config :ivhs_broker, IvhsBrokerWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: IvhsBrokerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: IvhsBroker.PubSub

config :ivhs_broker, IvhsBroker.Repo, migration_primary_key: [name: :id, type: :binary_id]

config :esbuild,
  version: "0.27.2",
  ivhs_broker: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  path: System.get_env("ESBUILD_PATH") || raise("ESBUILD_PATH environment variable is not set")

config :tailwind,
  version: "4.2.3",
  ivhs_broker: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ],
  path: System.get_env("TAILWIND_PATH") || raise("TAILWIND_PATH environment variable is not set")

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ivhs_broker, IvhsBroker.Mqtt,
  adapter:
    {IvhsBroker.Mqtt.Adapter.Mqttx,
     handler: IvhsBroker.Mqtt.Adapter.Mqttx.Handler, handler_state: %{}}

import_config "#{config_env()}.exs"
