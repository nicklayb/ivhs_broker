defmodule IvhsBrokerWeb.Devices.Live do
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Devices
  alias IvhsBroker.Repo
  alias Box.Ecto.Pagination.Page
  use IvhsBrokerWeb, :live_view
  @page_size 10
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:devices, &fetch_devices/0)
      |> subscribe(["devices"])

    {:ok, socket}
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

  def handle_event("prev-page", _params, socket) do
    socket = update_async_result(socket, :devices, &Repo.prev/1)
    {:noreply, socket}
  end

  def handle_event("next-page", _params, socket) do
    socket = update_async_result(socket, :devices, &Repo.next/1)
    {:noreply, socket}
  end

  defp fetch_devices do
    {:ok, %{devices: Devices.list_devices(%{limit: @page_size})}}
  end
end
