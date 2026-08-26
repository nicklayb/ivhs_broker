import Config

config :ivhs_broker, IvhsBroker.Repo,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :ivhs_broker, IvhsBrokerWeb.Endpoint,
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:ivhs_broker, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:ivhs_broker, ~w(--watch)]}
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
