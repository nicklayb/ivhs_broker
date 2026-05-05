import Config

config :caltar,
  environment: config_env(),
  ecto_repos: [Caltar.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :caltar, CaltarWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: CaltarWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Caltar.PubSub

config :esbuild,
  version: "0.27.2",
  caltar: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  path: System.get_env("ESBUILD_PATH") || raise("ESBUILD_PATH environment variable is not set")

config :tailwind,
  version: "4.2.3",
  caltar: [
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

import_config "#{config_env()}.exs"
