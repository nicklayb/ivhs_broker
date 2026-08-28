defmodule IvhsBrokerWeb.Devices.Show do
  alias Phoenix.LiveView.AsyncResult
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Devices
  use IvhsBrokerWeb, :live_view

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:device, AsyncResult.loading())
      |> start_async(:device, fn -> fetch_device(params) end)

    {:ok, socket}
  end

  def handle_async(:device, {:ok, device}, socket) do
    socket =
      socket
      |> assign(:device, AsyncResult.ok(socket.assigns.device, device))
      |> subscribe()

    {:noreply, socket}
  end

  def handle_async(:device, error, socket) do
    socket =
      socket
      |> assign(:device, AsyncResult.failed(socket.assigns.device, error))
      |> subscribe()

    {:noreply, socket}
  end

  defp fetch_device(params) do
    with reader_name when not is_nil(reader_name) <- Map.get(params, "reader_name"),
         {:ok, %Device{} = device} <- Devices.get_device(reader_name) do
      device
    else
      _ ->
        raise Ecto.NoResultsError, queryable: Device
    end
  end

  defp subscribe(socket) do
    topics = device_topics(socket.assigns.device)

    socket
    |> unsubscribe_all()
    |> subscribe(topics)
  end

  defp device_topics(%AsyncResult{ok?: true, result: %Device{reader_name: reader_name}}) do
    ["devices:#{reader_name}"]
  end

  defp device_topics(_), do: []
end
