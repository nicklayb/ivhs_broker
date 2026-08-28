defmodule IvhsBrokerWeb.Logs.Index do
  alias IvhsBroker.CardReads
  use IvhsBrokerWeb, :live_view
  alias Box.Ecto.Pagination.Page

  alias IvhsBroker.Repo
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Schema.Card

  @page_size 10

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:logs, &fetch_logs/0)
      |> subscribe(["card_reads"])
      |> assign_observable(count_card_reads: fn -> CardReads.count_card_reads() end)

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
    socket =
      update_async_result(socket, :logs, fn page ->
        page
        |> Repo.prev()
        |> preload()
      end)

    {:noreply, socket}
  end

  def handle_event("next-page", _params, socket) do
    socket =
      update_async_result(socket, :logs, fn page ->
        page
        |> Repo.next()
        |> preload()
      end)

    {:noreply, socket}
  end

  defp fetch_logs do
    logs =
      %{limit: @page_size}
      |> CardReads.list_card_reads()
      |> preload()

    {:ok, %{logs: logs}}
  end

  defp preload(%Page{} = page) do
    Page.map_every_results(page, &preload/1)
  end

  defp preload(results) do
    Repo.preload(results, [:card, :device])
  end
end
