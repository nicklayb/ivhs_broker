defmodule IvhsBroker.Mqtt.Adapter do
  @type client :: any()
  @type topic :: String.t()
  @type payload :: String.t()
  @type options :: Keyword.t()

  @callback connect(options()) :: {:ok, client()} | {:error, any()}
  @callback disconnect(client()) :: :ok | {:error, any()}

  @callback publish(client(), topic(), payload(), options()) ::
              :ok | {:error, any()}
  @callback subscribe(client(), topic(), options()) :: :ok | {:error, any()}

  @callback child_spec(options()) :: Supervisor.child_spec()
end
