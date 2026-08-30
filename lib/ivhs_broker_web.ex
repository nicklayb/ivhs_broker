defmodule IvhsBrokerWeb do
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: IvhsBrokerWeb.Layouts]

      use Gettext, backend: IvhsBrokerWeb.Gettext

      import Plug.Conn

      unquote(view_helpers())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: IvhsBrokerWeb.Endpoint,
        router: IvhsBrokerWeb.Router,
        statics: IvhsBrokerWeb.static_paths()
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView
      unquote(view_helpers())
    end
  end

  def view_helpers do
    quote do
      use IvhsBrokerWeb.Gettext
      alias Box.Html
      alias IvhsBrokerWeb.Components
      alias IvhsBrokerWeb.Components.Layouts
      import IvhsBrokerWeb.Helpers
      import PolymorphicEmbed.HTML.Component
      import PolymorphicEmbed.HTML.Helpers
      unquote(verified_routes())
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
