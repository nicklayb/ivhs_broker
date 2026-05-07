defmodule CaltarWeb.Authentication do
  alias Caltar.Accounts
  alias Caltar.Schema.User

  @session_key "user_id"

  def login_user(%Plug.Conn{} = conn, %User{id: user_id}) do
    Plug.Conn.put_session(conn, @session_key, user_id)
  end

  def authenticate(%Phoenix.LiveView.Socket{assigns: %{current_user: %User{}}} = socket, _session) do
    {:ok, socket}
  end

  def authenticate(%Phoenix.LiveView.Socket{} = socket, session) do
    case user_from_session(session) do
      {:ok, %User{} = user} ->
        {:ok, Phoenix.Component.assign(socket, :current_user, user)}

      _ ->
        {:error, socket}
    end
  end

  def get_session(%Plug.Conn{} = plug) do
    plug
    |> Plug.Conn.get_session(@session_key)
    |> Box.Result.from_nil()
  end

  def get_session(session), do: Map.fetch(session, @session_key)

  def user_from_session(conn_or_session) do
    with {:ok, user_id} <- get_session(conn_or_session),
         {:ok, %User{id: ^user_id} = user} <- Accounts.get_user_by_id(user_id) do
      {:ok, user}
    else
      _ ->
        :error
    end
  end
end
