defmodule IvhsBrokerWeb.Plugs.LoadUser do
  alias IvhsBroker.Schema.User
  alias IvhsBrokerWeb.Authentication

  require Logger

  def init(_) do
    []
  end

  def call(%Plug.Conn{} = conn, _) do
    case Authentication.user_from_session(conn) do
      {:ok, %User{} = user} ->
        Logger.debug("[#{inspect(__MODULE__)}] Loaded User #{user.email}")

        conn
        |> Plug.Conn.assign(:current_user, user)
        |> Plug.Conn.assign(:session_id, Ecto.UUID.generate())

      _ ->
        Logger.debug("[#{inspect(__MODULE__)}] No user in session")
        conn
    end
  end
end
