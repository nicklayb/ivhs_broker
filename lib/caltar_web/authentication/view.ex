defmodule CaltarWeb.Authentication.View do
  use CaltarWeb, :component

  alias CaltarWeb.Components.Form
  alias CaltarWeb.Components.Layouts

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
