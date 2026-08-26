defmodule IvhsBrokerWeb.Authentication.Controller do
  use IvhsBrokerWeb, :controller

  alias IvhsBroker.Accounts
  alias IvhsBroker.Schema.User
  alias IvhsBrokerWeb.Authentication

  plug(:put_view, html: IvhsBrokerWeb.Authentication.View)

  action_fallback(IvhsBrokerWeb.Error.Controller)

  def login(conn, _params) do
    render(conn, "login.html", changeset: login_changeset())
  end

  def post_login(conn, %{"login_form" => %{"email" => email, "password" => password}}) do
    case Accounts.login(email, password) do
      {:ok, %User{} = user} ->
        conn
        |> Plug.Conn.clear_session()
        |> Authentication.login_user(user)
        |> Phoenix.Controller.redirect(to: ~p(/app))

      _ ->
        changeset =
          %{email: email}
          |> login_changeset()
          |> Map.put(:action, :insert)
          |> Ecto.Changeset.add_error(:email, "invalid email or password")

        render(conn, "login.html", changeset: changeset)
    end
  end

  def logout(conn, _) do
    conn
    |> Plug.Conn.clear_session()
    |> Phoenix.Controller.redirect(to: ~p(/))
    |> Plug.Conn.halt()
  end

  @types %{email: :string, password: :string}
  @permitted Map.keys(@types)
  @changeset {%{}, @types}
  defp login_changeset(params \\ %{}) do
    Ecto.Changeset.cast(@changeset, params, @permitted)
  end
end
