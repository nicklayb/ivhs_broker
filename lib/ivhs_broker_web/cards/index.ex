defmodule IvhsBrokerWeb.Cards.Index do
  alias IvhsBroker.Schema.Card
  alias Phoenix.LiveView.AsyncResult
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Cards
  alias IvhsBroker.Repo
  alias Box.Ecto.Pagination.Page
  use IvhsBrokerWeb, :live_view
  @page_size 10
  def mount(params, _session, socket) do
    filter = Cards.Filter.new(params)

    target_options =
      Card
      |> PolymorphicEmbed.types(:target)
      |> Enum.map(&{&1, &1})
      |> then(&[{"all", gettext("All targets")}, {"without", gettext("No target")} | &1])

    socket =
      socket
      |> assign(:cards, AsyncResult.loading())
      |> start_async(:cards, fn -> fetch_cards(filter) end)
      |> assign(:target_options, target_options)
      |> assign_observable(count_cards: fn -> Cards.count_cards() end)
      |> assign(:filter, filter)

    {:ok, socket}
  end

  def handle_async(:cards, {:ok, cards}, socket) do
    socket =
      socket
      |> assign(:cards, AsyncResult.ok(socket.assigns.cards, cards))
      |> subscribe()

    {:noreply, socket}
  end

  def handle_async(:cards, error, socket) do
    socket =
      socket
      |> assign(:cards, AsyncResult.failed(socket.assigns.cards, error))
      |> subscribe()

    {:noreply, socket}
  end

  def handle_info(
        %Box.PubSub.Message{topic: "cards", params: %Card{} = card},
        socket
      ) do
    socket =
      socket
      |> update_async_result(:cards, fn %Page{results: cards} = page ->
        %Page{page | results: Enum.take([card | cards], @page_size)}
      end)
      |> subscribe()

    {:noreply, socket}
  end

  def handle_info(
        %Box.PubSub.Message{
          topic: "cards:" <> uid,
          message: :updated,
          params: %Card{} = updated_card
        },
        socket
      ) do
    socket =
      update_async_result(socket, :cards, fn %Page{} = page ->
        Page.map_every_results(page, fn
          %Card{uid: ^uid, card_reads: card_reads} ->
            %Card{updated_card | card_reads: card_reads}

          card ->
            card
        end)
      end)

    {:noreply, socket}
  end

  def handle_info(
        %Box.PubSub.Message{
          topic: "cards:" <> uid,
          message: :new_entry,
          params: %CardRead{} = card_read
        },
        socket
      ) do
    socket =
      update_async_result(socket, :cards, fn %Page{} = page ->
        Page.map_every_results(page, fn
          %Card{uid: ^uid} = card ->
            %Card{card | card_reads: [card_read]}

          card ->
            card
        end)
      end)

    {:noreply, socket}
  end

  def handle_event("filters:change", params, socket) do
    filter = Cards.Filter.update(socket.assigns.filter, params)

    socket =
      socket
      |> assign(:filter, filter)
      |> debounce_async(:cards, fn -> fetch_cards(filter) end)

    {:noreply, socket}
  end

  def handle_event("prev-page", _params, socket) do
    socket =
      socket
      |> update_async_result(:cards, &Repo.prev/1)
      |> subscribe()

    {:noreply, socket}
  end

  def handle_event("next-page", _params, socket) do
    socket =
      socket
      |> update_async_result(:cards, &Repo.next/1)
      |> subscribe()

    {:noreply, socket}
  end

  defp fetch_cards(filter) do
    Cards.list_cards(filter: filter, pagination: %{limit: @page_size})
  end

  defp subscribe(socket) do
    topics = ["cards"] ++ card_topics(socket.assigns.cards)

    subscribe(socket, topics)
  end

  defp card_topics(%AsyncResult{ok?: true, result: %Page{results: results}}) do
    Enum.map(results, &"cards:#{&1.uid}")
  end

  defp card_topics(_), do: []
end
