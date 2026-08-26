defmodule IvhsBroker.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IvhsBroker.Repo,
      IvhsBroker.CardConsumer,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:ivhs_broker, :ecto_repos), skip: skip_migrations?()},
      IvhsBroker.PubSub,
      IvhsBrokerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: IvhsBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    IvhsBrokerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    System.get_env("RELEASE_NAME") != nil
  end
end
