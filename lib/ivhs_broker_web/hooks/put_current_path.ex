defmodule IvhsBrokerWeb.Hooks.PutCurrentPath do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, session, socket) do
    socket =
      socket
      |> attach_hook(:current_path, :handle_params, &handle_params/3)
      |> assign(:current_path, session["current_path"])

    {:cont, socket}
  end

  defp handle_params(_params, uri, socket) do
    path = URI.parse(uri).path

    {:cont, assign(socket, :current_path, path)}
  end
end
