defmodule Caltar.MixProject do
  use Mix.Project

  def project do
    [
      app: :caltar,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Caltar.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:bandit, "~> 1.10.4"},
      {:box, git: "https://github.com/nicklayb/box_ex.git", tag: "0.17.5"},
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
      {:tz, "~> 0.28"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind caltar", "esbuild caltar"],
      "assets.deploy": [
        "tailwind caltar --minify",
        "esbuild caltar --minify",
        "phx.digest"
      ],
      gettext: [
        "gettext.extract",
        "gettext.merge priv/gettext"
      ]
    ]
  end
end
