defmodule IvhsBrokerWeb.Logs.Live do
  use IvhsBrokerWeb, :live_view

  alias IvhsBroker.Repo
  alias IvhsBroker.Schema.CardRead

  def mount(_params, _session, socket) do
    socket = assign_async(socket, :logs, &fetch_logs/0)
    {:ok, socket}
  end

  defp fetch_logs do
    {:ok, %{logs: Repo.all(CardRead)}}
  end
end
