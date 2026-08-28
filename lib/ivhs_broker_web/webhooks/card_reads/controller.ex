defmodule IvhsBrokerWeb.Webhooks.CardReads.Controller do
  use IvhsBrokerWeb, :controller

  require Logger

  alias IvhsBroker.CardConsumer
  alias IvhsBroker.CardConsumer.UpdatedMessage

  def create(conn, params) do
    with {:ok, %UpdatedMessage{} = message} <- UpdatedMessage.init(params) do
      CardConsumer.handle(message)
      send_resp(conn, :ok, "")
    else
      {:error, changeset} ->
        Logger.error("[#{inspect(__MODULE__)}] [error] #{inspect(changeset)}")
        send_resp(conn, :bad_request, "")
    end
  end
end
