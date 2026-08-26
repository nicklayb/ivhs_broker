defmodule IvhsBrokerWeb.Plugs.EnsureAuthenticated do
  alias IvhsBroker.Schema.User

  use IvhsBrokerWeb, :verified_routes

  require Logger

  def init(authenticated: authenticated) do
    %{authenticated: authenticated}
  end

  def call(%Plug.Conn{assigns: %{current_user: %User{}}} = conn, %{authenticated: true}) do
    Logger.debug("[#{inspect(__MODULE__)}] Successfully ensured user logged in")
    conn
  end

  def call(%Plug.Conn{assigns: %{current_user: %User{email: email}}} = conn, %{
        authenticated: false
      }) do
    Logger.debug("[#{inspect(__MODULE__)}] Failure to ensure user offline (#{email} loaded)")

    conn
    |> Phoenix.Controller.redirect(to: ~p(/app))
    |> Plug.Conn.halt()
  end

  def call(%Plug.Conn{} = conn, %{authenticated: true}) do
    Logger.debug("[#{inspect(__MODULE__)}] Failure to ensure user logged in")

    conn
    |> Phoenix.Controller.put_flash(:error, "You're not authenticated")
    |> Phoenix.Controller.redirect(to: "/")
    |> Plug.Conn.halt()
  end

  def call(%Plug.Conn{} = conn, _) do
    Logger.debug("[#{inspect(__MODULE__)}] Successfully ensured user offline")
    conn
  end
end
