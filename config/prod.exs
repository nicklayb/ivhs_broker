import Config

config :ivhs_broker, IvhsBrokerWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :ivhs_broker, IvhsBrokerWeb.Endpoint, server: true
