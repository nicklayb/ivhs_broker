defmodule IvhsBrokerWeb.Hooks.Authenticated do
  alias IvhsBrokerWeb.Authentication
  use IvhsBrokerWeb, :verified_routes

  def on_mount(:default, _params, session, socket) do
    socket
    |> Phoenix.Component.assign_new(:current_user, fn -> nil end)
    |> authenticate(session)
  end

  defp authenticate(socket, session) do
    case Authentication.authenticate(socket, session) do
      {:ok, socket} ->
        {:cont, socket}

      _ ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p(/logout))}
    end
  end
end
