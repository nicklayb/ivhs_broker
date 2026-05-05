defmodule CaltarWeb.Router do
  use CaltarWeb, :router

  import Phoenix.LiveView.Router

  pipeline(:browser) do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {CaltarWeb.Components.Layouts, :root})
    plug(:put_layout, {CaltarWeb.Components.Layouts, :app})
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
    plug(:put_layout, {CaltarWeb.Components.Layouts, :offline})
  end

  scope("/", CaltarWeb) do
    pipe_through([:browser])
    live("/", Main.Live)
  end

  scope("/", CaltarWeb) do
    pipe_through([:browser, :session_offline])

    get("/", Authentication.Controller, :login)
    get("/login", Authentication.Controller, :login)
    post("/login", Authentication.Controller, :post_login)
  end

  scope("/", GalerieWeb) do
    pipe_through([:browser])
    get("/logout", Authentication.Controller, :logout)
  end
end
