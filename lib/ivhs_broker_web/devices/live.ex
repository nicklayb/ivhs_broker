defmodule IvhsBrokerWeb.Devices.Live do
  use IvhsBrokerWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
