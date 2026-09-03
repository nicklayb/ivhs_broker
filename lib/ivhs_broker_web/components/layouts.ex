defmodule IvhsBrokerWeb.Components.Layouts do
  use IvhsBrokerWeb, :component

  embed_templates("layouts/*")

  @default "flex flex-col bg-gray-200 border-l-4 py-3 px-2 mb-2 rounded-r-md"
  @class %{
    info: "#{@default} border-yellow-600 text-gray-800",
    error: "#{@default} border-red-800 text-gray-800"
  }
  attr(:message, :string, required: true)
  attr(:type, :atom, required: true)

  def message(%{type: type} = assigns) do
    assigns = assign(assigns, :class, Map.fetch!(@class, type))

    ~H"""
    <%= if @message do %>
      <div class={@class}>
        <%= for message <- List.wrap(@message) do %>
          <span class="">{message}</span>
        <% end %>
      </div>
    <% end %>
    """
  end

  def logo(assigns) do
    ~H"""
    <h1 class="text-4xl text-pink-400 font-bold uppercase tracking-wide">IvhsBroker</h1>
    """
  end

  def nav do
    [
      %{name: gettext("Logs"), link: ~p"/logs"},
      %{name: gettext("Devices"), link: ~p"/devices"},
      %{name: gettext("Cards"), link: ~p"/cards"}
      # %{name: gettext("Settings"), link: ~p"/settings"}
    ]
  end
end
