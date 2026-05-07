defmodule CaltarWeb.Error.Controller do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> halt()
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(400)
    |> halt()
  end
end
