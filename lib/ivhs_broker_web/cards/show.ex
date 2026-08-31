defmodule IvhsBrokerWeb.Cards.Show do
  alias Phoenix.LiveView.AsyncResult
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.Card.Target
  alias IvhsBroker.Client.Plex, as: PlexClient
  alias IvhsBroker.Cards
  alias IvhsBrokerWeb.Cards.Show.Target, as: TargetForm
  use IvhsBrokerWeb, :live_view

  @targets [
    {"raw", "Raw"},
    {"plex", "Plex"},
    {"youtube", "YouTube"}
  ]

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.loading())
      |> assign(:targets, @targets)
      |> assign(:plex_search_value, "")
      |> assign(:plex_results, [])
      |> start_async(:card, fn -> fetch_card(params) end)

    {:ok, socket}
  end

  def handle_async(:card, {:ok, card}, socket) do
    socket =
      socket
      |> assign(:card, AsyncResult.ok(socket.assigns.card, card))
      |> subscribe()
      |> assign_target_form()
      |> assign(:label_form, nil)

    {:noreply, socket}
  end

  def handle_async(:card, error, socket) do
    socket = assign(socket, :card, AsyncResult.failed(socket.assigns.card, error))

    {:noreply, socket}
  end

  def handle_async(:search_plex, {:ok, videos}, socket) do
    socket = assign(socket, :plex_results, videos)
    {:noreply, socket}
  end

  def handle_async(:search_plex, {:error, _error}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "change_target",
        %{"_target" => ["plex_search"], "plex_search" => plex_search},
        socket
      ) do
    socket = debounce_async(socket, :search_plex, fn -> search_plex(plex_search) end)
    {:noreply, socket}
  end

  def handle_event("edit_label", _params, socket) do
    socket = assign_label_form(socket)
    {:noreply, socket}
  end

  def handle_event("select_plex_result", params, socket) do
    socket = submit_target(socket, %{"target" => params})
    {:noreply, socket}
  end

  def handle_event("add_target", _, socket) do
    socket = assign_target_form(socket, %{"target" => %{"__type__" => "raw"}})

    {:noreply, socket}
  end

  def handle_event("remove_target", _, socket) do
    socket = submit_target(socket, %{"target" => nil})

    {:noreply, socket}
  end

  def handle_event("change_target", %{"card" => %{"target" => %{"__type__" => "none"}}}, socket) do
    socket = submit_target(socket, %{"target" => nil})
    {:noreply, socket}
  end

  def handle_event("change_label", %{"card" => params}, socket) do
    socket = assign_label_form(socket, params)
    {:noreply, socket}
  end

  def handle_event("submit_label", %{"card" => params}, socket) do
    socket = submit_label(socket, params)

    {:noreply, socket}
  end

  def handle_event("change_target", %{"card" => params}, socket) do
    socket = assign_target_form(socket, params)
    {:noreply, socket}
  end

  def handle_event("submit_target", %{"card" => params}, socket) do
    socket = submit_target(socket, params)

    {:noreply, socket}
  end

  defp submit_label(socket, params) do
    with %Ecto.Changeset{valid?: true} <- build_label_form(socket, params),
         {:ok, %Card{} = card} <-
           IvhsBroker.UseCase.execute(
             IvhsBroker.UseCase.Cards.Update,
             {socket.assigns.card.result.uid, params}
           ) do
      socket
      |> update_async_result(:card, fn _ -> card end)
      |> assign(:label_form, nil)
    else
      %Ecto.Changeset{} = changeset ->
        assign_label_form(socket, changeset)

      {:error, _} ->
        socket
    end
  end

  defp submit_target(socket, params) do
    with %Ecto.Changeset{valid?: true} <- build_target_form(socket, params),
         {:ok, %Card{} = card} <-
           IvhsBroker.UseCase.execute(
             IvhsBroker.UseCase.Cards.UpdateTarget,
             {socket.assigns.card.result.uid, params}
           ) do
      socket
      |> update_async_result(:card, fn _ -> card end)
      |> assign_target_form()
    else
      %Ecto.Changeset{} = changeset ->
        assign_target_form(socket, changeset)

      {:error, _} ->
        socket
    end
  end

  defp search_plex(plex_search) do
    {:ok, %{videos: videos}} = PlexClient.search(plex_search)
    videos
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

  defp assign_label_form(socket, params \\ %{})

  defp assign_label_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :label_form, to_form(changeset))
  end

  defp assign_label_form(socket, params) do
    changeset = build_label_form(socket, params)

    assign_label_form(socket, changeset)
  end

  defp build_label_form(socket, params) do
    Card.update_changeset(socket.assigns.card.result, params)
  end

  defp assign_target_form(socket, params \\ %{})

  defp assign_target_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :target_form, to_form(changeset))
  end

  defp assign_target_form(socket, params) do
    changeset = build_target_form(socket, params)

    assign_target_form(socket, changeset)
  end

  defp build_target_form(socket, params) do
    Card.target_changeset(socket.assigns.card.result, params)
  end
end
