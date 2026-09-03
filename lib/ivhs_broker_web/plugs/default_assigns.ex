defmodule IvhsBrokerWeb.Plugs.DefaultAssigns do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_session(:current_path, conn.request_path)
    |> put_new_session(:session_id, Ecto.UUID.generate())
  end

  defp put_new_session(conn, key, value) do
    if get_session(conn, key) do
      conn
    else
      put_session(conn, key, value)
    end
  end
end
