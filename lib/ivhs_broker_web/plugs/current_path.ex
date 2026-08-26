defmodule IvhsBrokerWeb.Plugs.CurrentPath do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    put_session(conn, :current_path, conn.request_path)
  end
end
