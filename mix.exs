defmodule IvhsBroker.MixProject do
  use Mix.Project

  @version "VERSION" |> File.read!() |> String.trim()

  def project do
    [
      app: :ivhs_broker,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  def application do
    [
      mod: {IvhsBroker.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:bandit, "~> 1.10.4"},
      {:box, git: "https://github.com/nicklayb/box_ex.git", tag: "0.17.10"},
      {:credo, "~> 1.7.18", runtime: false, only: ~w(dev test)a},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, "~> 0.22"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.26"},
      {:plug, "~> 1.18", [optional: false]},
      {:jason, "~> 1.2"},
      {:phoenix, "~> 1.8.5"},
      {:phoenix_live_view, "~> 1.1.28"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:tz, "~> 0.28"},
      {:phoenix_ecto, "~> 4.5"},
      {:mqttx, "~> 0.11.0"},
      {:thousand_island, "~> 1.4"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind ivhs_broker", "esbuild ivhs_broker"],
      "assets.deploy": [
        "tailwind ivhs_broker --minify",
        "esbuild ivhs_broker --minify",
        "phx.digest"
      ],
      gettext: [
        "gettext.extract",
        "gettext.merge priv/gettext"
      ]
    ]
  end
end
