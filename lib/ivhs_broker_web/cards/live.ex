defmodule IvhsBrokerWeb.Cards.Live do
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Cards
  alias IvhsBroker.Repo
  alias Box.Ecto.Pagination.Page
  use IvhsBrokerWeb, :live_view
  @page_size 10
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:cards, &fetch_cards/0)
      |> subscribe(["cards"])

    {:ok, socket}
  end

  def handle_info(
        %Box.PubSub.Message{topic: "cards", params: %Card{} = card},
        socket
      ) do
    socket =
      update_async_result(socket, :cards, fn %Page{results: cards} = page ->
        %Page{page | results: Enum.take([card | cards], @page_size)}
      end)

    {:noreply, socket}
  end

  def handle_event("prev-page", _params, socket) do
    socket = update_async_result(socket, :cards, &Repo.prev/1)
    {:noreply, socket}
  end

  def handle_event("next-page", _params, socket) do
    socket = update_async_result(socket, :cards, &Repo.next/1)
    {:noreply, socket}
  end

  defp fetch_cards do
    {:ok, %{cards: Cards.list_cards(%{limit: @page_size})}}
  end
end
