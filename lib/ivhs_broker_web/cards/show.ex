defmodule IvhsBrokerWeb.Cards.Show do
  alias Phoenix.LiveView.AsyncResult
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Cards
  use IvhsBrokerWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.loading())
      |> start_async(:card, fn -> fetch_card(params) end)

    {:ok, socket}
  end

  def handle_async(:card, {:ok, card}, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.ok(socket.assigns.card, card))
      |> subscribe()

    {:noreply, socket}
  end

  def handle_async(:card, error, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.failed(socket.assigns.card, error))
      |> subscribe()

    {:noreply, socket}
  end

  defp fetch_card(params) do
    with uid when not is_nil(uid) <- Map.get(params, "uid"),
         {:ok, %Card{} = card} <- Cards.get_card(uid) do
      card
    else
      _ ->
        raise Ecto.NoResultsError, queryable: Card
    end
  end

  defp subscribe(socket) do
    topics = card_topics(socket.assigns.card)

    socket
    |> unsubscribe_all()
    |> subscribe(topics)
  end

  defp card_topics(%AsyncResult{ok?: true, result: %Card{uid: uid}}) do
    ["cards:#{uid}"]
  end

  defp card_topics(_), do: []
end
