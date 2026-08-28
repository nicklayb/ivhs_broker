defmodule IvhsBrokerWeb.Router do
  use Phoenix.Router

  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router

  alias IvhsBrokerWeb.Hooks

  pipeline(:browser) do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {IvhsBrokerWeb.Components.Layouts, :root})
    plug(:put_layout, {IvhsBrokerWeb.Components.Layouts, :app})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(IvhsBrokerWeb.Plugs.CurrentPath)
  end

  live_session :default, on_mount: [Hooks.PutCurrentPath, Hooks.PutDefaultAssigns] do
    scope("/", IvhsBrokerWeb) do
      pipe_through([:browser])
      live("/", Logs.Index)
      live("/devices", Devices.Index)
      live("/devices/:reader_name", Devices.Show)
      live("/cards", Cards.Index)
      live("/cards/:uid", Cards.Show)
      live("/settings", Settings.Index)
    end
  end
end
