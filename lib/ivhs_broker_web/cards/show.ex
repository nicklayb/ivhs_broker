defmodule IvhsBrokerWeb.Cards.Show do
  alias Phoenix.LiveView.AsyncResult
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.Card.Target
  alias IvhsBroker.Cards
  use IvhsBrokerWeb, :live_view

  @targets [
    {"raw", "Raw"},
    {"plex", "Plex"}
  ]

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.loading())
      |> assign(:targets, @targets)
      |> start_async(:card, fn -> fetch_card(params) end)

    {:ok, socket}
  end

  def handle_async(:card, {:ok, card}, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.ok(socket.assigns.card, card))
      |> subscribe()
      |> assign_form()

    {:noreply, socket}
  end

  def handle_async(:card, error, socket) do
    socket = assign(socket, :card, AsyncResult.failed(socket.assigns.card, error))

    {:noreply, socket}
  end

  def handle_event("change", %{"card" => params}, socket) do
    socket = assign_form(socket, params)
    {:noreply, socket}
  end

  def handle_event("submit", %{"card" => params}, socket) do
    socket =
      with %Ecto.Changeset{valid?: true} <- build_form(socket, params),
           {:ok, %Card{} = card} <-
             IvhsBroker.UseCase.execute(
               IvhsBroker.UseCase.Cards.UpdateTarget,
               {socket.assigns.card.result.uid, params}
             ) do
        update_async_result(socket, :card, fn _ -> card end)
      else
        %Ecto.Changeset{} = changeset ->
          assign_form(socket, changeset)

        {:error, _} ->
          socket
      end

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

  defp assign_form(socket, params \\ %{})

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_form(socket, params) do
    changeset = build_form(socket, params)

    assign_form(socket, changeset)
  end

  defp build_form(socket, params) do
    Card.target_changeset(socket.assigns.card.result, params)
  end
end
