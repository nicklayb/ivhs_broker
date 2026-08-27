defmodule IvhsBrokerWeb.Logs.Live do
  alias IvhsBroker.CardReads
  use IvhsBrokerWeb, :live_view
  alias Box.Ecto.Pagination.Page

  alias IvhsBroker.Repo
  alias IvhsBroker.Schema.CardRead

  @page_size 10

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:logs, &fetch_logs/0)
      |> subscribe(["card_reads"])

    {:ok, socket}
  end

  def handle_info(
        %Box.PubSub.Message{topic: "card_reads", params: %CardRead{} = card_read},
        socket
      ) do
    socket =
      update_async_result(socket, :logs, fn %Page{results: logs} = page ->
        %Page{page | results: Enum.take([card_read | logs], @page_size)}
      end)

    {:noreply, socket}
  end

  def handle_event("prev-page", _params, socket) do
    socket = update_async_result(socket, :logs, &Repo.prev/1)
    {:noreply, socket}
  end

  def handle_event("next-page", _params, socket) do
    socket = update_async_result(socket, :logs, &Repo.next/1)
    {:noreply, socket}
  end

  defp fetch_logs do
    {:ok, %{logs: CardReads.list_card_reads(%{limit: @page_size})}}
  end
end
