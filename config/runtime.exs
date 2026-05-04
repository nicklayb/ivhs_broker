import Config

config :caltar, release_name: Box.Config.get("RELEASE_NAME")

config :caltar, Caltar.Repo,
  url:
    Box.Config.get!("DATABASE_PATH",
      dev: "postgresql://postgres:postgres@localhost/caltar_dev",
      test: "postgresql://postgres:postgres@localhost/caltar_test"
    ),
  pool_size: Box.Config.int("POOL_SIZE", default: "5")

app_host = Box.Config.uri("APP_HOST", default: "http://localhost:4000")
port = Box.Config.int("PORT", default: "4000")

config :caltar, CaltarWeb.Endpoint,
  http: [port: port],
  url: [host: app_host.host, scheme: app_host.scheme, port: app_host.port],
  secret_key_base: Box.Config.get!("SECRET_KEY_BASE"),
  live_view: [signing_salt: Box.Config.get!("LIVE_VIEW_SALT")]
