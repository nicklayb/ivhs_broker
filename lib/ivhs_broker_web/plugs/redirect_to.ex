defmodule IvhsBrokerWeb.Plugs.RedirectTo do
  import Phoenix.Controller, only: [redirect: 2]

  def init(opts), do: opts

  def call(conn, opts) do
    path = Keyword.fetch!(opts, :to)
    redirect(conn, to: path)
  end
end
