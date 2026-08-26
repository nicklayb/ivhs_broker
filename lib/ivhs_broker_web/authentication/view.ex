defmodule IvhsBrokerWeb.Authentication.View do
  use IvhsBrokerWeb, :component

  alias IvhsBrokerWeb.Components.Form
  alias IvhsBrokerWeb.Components.Layouts

  embed_templates("templates/*")

  slot(:inner_block, required: true)

  def container(assigns) do
    ~H"""
    <div class="bg-gray-200 rounded-lg p-4">
      <div class="text-center my-4">
        <Layouts.logo />
      </div>

      {render_slot(@inner_block)}
    </div>
    """
  end
end
