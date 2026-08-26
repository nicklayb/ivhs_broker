defmodule IvhsBrokerWeb.Router do
  use Phoenix.Router

  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router

  alias IvhsBrokerWeb.Plugs

  pipeline(:browser) do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {IvhsBrokerWeb.Components.Layouts, :root})
    plug(:put_layout, {IvhsBrokerWeb.Components.Layouts, :app})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline(:session_authenticated) do
    plug(Plugs.LoadUser)
    plug(Plugs.EnsureAuthenticated, authenticated: true)
  end

  pipeline(:session_offline) do
    plug(Plugs.LoadUser)
    plug(Plugs.EnsureAuthenticated, authenticated: false)
    plug(:put_layout, {IvhsBrokerWeb.Components.Layouts, :offline})
  end

  scope("/app", IvhsBrokerWeb) do
    pipe_through([:browser])
    live("/", Main.Live)
  end

  scope("/", IvhsBrokerWeb) do
    pipe_through([:browser, :session_offline])

    get("/", Authentication.Controller, :login)
    get("/login", Authentication.Controller, :login)
    post("/login", Authentication.Controller, :post_login)
  end

  scope("/", IvhsBrokerWeb) do
    pipe_through([:browser])
    get("/logout", Authentication.Controller, :logout)
  end
end
