defmodule IvhsBrokerWeb.Hooks.PutDefaultAssigns do
  import Phoenix.Component

  require Logger

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> assign(:__topics__, [])
      |> assign(:__observables__, %{})
      |> Phoenix.LiveView.attach_hook(:handle_obsverables, :handle_info, &handle_observable/2)

    {:cont, socket}
  end

  defp handle_observable(
         {IvhsBroker.Cache, key, payload},
         %{assigns: %{__observables__: observables}} = socket
       )
       when is_map_key(observables, key) do
    socket =
      case payload do
        {:inserted, value} ->
          assign(socket, key, value)

        :deleted ->
          function = Map.fetch!(observables, key)
          assign(socket, key, function.())
      end

    {:halt, socket}
  end

  defp handle_observable(
         {IvhsBroker.Cache, key, payload},
         socket
       ) do
    Logger.warning(
      "[#{inspect(socket.view)}] [#{key}] [unhandled observable] #{inspect(payload)}"
    )

    {:halt, socket}
  end

  defp handle_observable(_, socket), do: {:cont, socket}
end
