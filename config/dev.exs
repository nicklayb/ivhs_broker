import Config

config :ivhs_broker, IvhsBroker.Repo,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :ivhs_broker, IvhsBrokerWeb.Endpoint,
  check_origin: false,
  # code_reloader: true,
  debug_errors: true,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:ivhs_broker, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:ivhs_broker, ~w(--watch)]}
  ],
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!.*local_storage).*(js|css|png|jpeg|jpg|gif|svg|json)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ivhs_broker_web/.*/.*(ex|eex)$"
    ]
  ],
  reloadable_compilers: [:gettext, :phoenix, :elixir]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
