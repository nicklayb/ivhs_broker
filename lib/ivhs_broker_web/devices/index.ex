defmodule IvhsBrokerWeb.Devices.Index do
  alias Phoenix.LiveView.AsyncResult
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Devices
  alias IvhsBroker.Repo
  alias Box.Ecto.Pagination.Page
  use IvhsBrokerWeb, :live_view
  @page_size 10
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:devices, AsyncResult.loading())
      |> start_async(:devices, &fetch_devices/0)
      |> assign_observable(count_devices: fn -> Devices.count_devices() end)

    {:ok, socket}
  end

  def handle_async(:devices, {:ok, devices}, socket) do
    socket =
      socket
      |> assign(:devices, AsyncResult.ok(socket.assigns.devices, devices))
      |> subscribe()

    {:noreply, socket}
  end

  def handle_async(:devices, error, socket) do
    socket =
      socket
      |> assign(:devices, AsyncResult.failed(socket.assigns.devices, error))
      |> subscribe()

    {:noreply, socket}
  end

  def handle_info(
        %Box.PubSub.Message{topic: "devices", params: %Device{} = device},
        socket
      ) do
    socket =
      update_async_result(socket, :devices, fn %Page{results: devices} = page ->
        %Page{page | results: Enum.take([device | devices], @page_size)}
      end)

    {:noreply, socket}
  end

  def handle_info(
        %Box.PubSub.Message{
          topic: "devices:" <> reader_name,
          message: :new_entry,
          params: %CardRead{} = card_read
        },
        socket
      ) do
    socket =
      update_async_result(socket, :devices, fn %Page{} = page ->
        Page.map_every_results(page, fn
          %Device{reader_name: ^reader_name} = device ->
            %Device{device | card_reads: [card_read]}

          device ->
            device
        end)
      end)

    {:noreply, socket}
  end

  def handle_event("prev-page", _params, socket) do
    socket =
      socket
      |> update_async_result(:devices, &Repo.prev/1)
      |> subscribe()

    {:noreply, socket}
  end

  def handle_event("next-page", _params, socket) do
    socket =
      socket
      |> update_async_result(:devices, &Repo.next/1)
      |> subscribe()

    {:noreply, socket}
  end

  defp fetch_devices do
    Devices.list_devices(%{limit: @page_size})
  end

  defp subscribe(socket) do
    topics = ["devices"] ++ device_topics(socket.assigns.devices)

    subscribe(socket, topics)
  end

  defp device_topics(%AsyncResult{ok?: true, result: %Page{results: results}}) do
    Enum.map(results, &"devices:#{&1.reader_name}")
  end

  defp device_topics(_), do: []
end
