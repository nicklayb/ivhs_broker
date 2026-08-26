defmodule IvhsBroker.CardConsumer do
  use GenServer

  require Logger

  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.CardConsumer.UpdatedMessage

  @usecase IvhsBroker.UseCase.CardReads.HandleCardEvent

  @default_name __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Keyword.get(args, :name, @default_name))
  end

  def handle(pid \\ @default_name, %UpdatedMessage{} = message) do
    GenServer.cast(pid, {:handle, message})
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_cast({:handle, %UpdatedMessage{} = message}, state) do
    with {:ok, %CardRead{} = card_read} <- dispatch_use_case(message) do
      Logger.info("[#{inspect(__MODULE__)}] #{inspect(card_read)}")
    end

    {:noreply, state}
  end

  defp dispatch_use_case(message) do
    IvhsBroker.UseCase.execute(@usecase, message)
  end
end
