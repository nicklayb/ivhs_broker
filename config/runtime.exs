import Config

config :ivhs_broker, release_name: Box.Config.get("RELEASE_NAME")

config :ivhs_broker, IvhsBroker.Repo,
  url:
    Box.Config.get!("DATABASE_PATH",
      dev: "postgresql://postgres:postgres@localhost/ivhs_broker_dev",
      test: "postgresql://postgres:postgres@localhost/ivhs_broker_test"
    ),
  pool_size: Box.Config.int("POOL_SIZE", default: "5")

app_host = Box.Config.uri("APP_HOST", default: "http://localhost:4000")
port = Box.Config.int("PORT", default: "4000")

config :ivhs_broker, IvhsBrokerWeb.Endpoint,
  http: [port: port],
  url: [host: app_host.host, scheme: app_host.scheme, port: app_host.port],
  secret_key_base: Box.Config.get!("SECRET_KEY_BASE"),
  live_view: [signing_salt: Box.Config.get!("LIVE_VIEW_SALT")]

config :logger, level: Box.Config.atom("LOGGER_LEVEL", default: "info")

config :ivhs_broker, IvhsBroker.Mqtt,
  host: Box.Config.get!("MQTT_HOST"),
  port: Box.Config.int("MQTT_PORT", default: "1883"),
  client_id: Box.Config.get("MQTT_CLIENT_ID", default: "ivhs"),
  username: Box.Config.get("MQTT_USERNAME"),
  password: Box.Config.get("MQTT_PASSWORD")
