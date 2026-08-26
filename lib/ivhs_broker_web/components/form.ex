defmodule IvhsBrokerWeb.Components.Form do
  use IvhsBrokerWeb, :component

  attr(:name, :atom, required: true)
  attr(:multiple, :boolean, default: false)
  attr(:errors, :list, default: [])
  attr(:class, :string, default: "")
  attr(:label_position, :atom, default: :above)
  slot(:inner_block, required: true)

  slot(:label, required: false) do
    attr(:class, :string, required: false)
  end

  def element(assigns) do
    name = multiple_name(assigns)
    assigns = assign(assigns, :name, name)

    ~H"""
    <div class={
      Box.Html.class("group", [
        {Enum.any?(@errors), "has-errors"},
        {@class != "", @class, "flex flex-col gap-y-1 mb-3"}
      ])
    }>
      <%= if Enum.any?(@label) and @label_position == :above do %>
        <label
          for={@name}
          class={
            Box.Html.class(
              "text-sm pl-0.5 group-[.has-errors]:text-red-400",
              slot_attr(@label, :class, "")
            )
          }
        >
          {render_slot(@label)}
        </label>
      <% end %>
      {render_slot(@inner_block)}
      <%= if Enum.any?(@label) and @label_position == :below do %>
        <label
          for={@name}
          class={
            Box.Html.class(
              "text-sm pl-0.5 group-[.has-errors]:text-red-400",
              slot_attr(@label, :class, "")
            )
          }
        >
          {render_slot(@label)}
        </label>
      <% end %>
      <.field_errors errors={@errors} />
    </div>
    """
  end

  attr(:field, :any, required: true)
  attr(:value, :any, required: true)
  attr(:element_class, :string, default: "")
  attr(:multiple, :boolean, default: false)
  attr(:checked, :boolean, required: true)

  slot(:label, required: false) do
    attr(:class, :string, required: false)
  end

  @classes "flex flex-row mb-3 items-center"

  def checkbox(assigns) do
    name = multiple_name(assigns)

    assigns =
      assigns
      |> assign(:name, name)
      |> update(:element_class, &Box.Html.class(@classes, &1))

    ~H"""
    <.element
      name={@field.name}
      errors={@field.errors}
      class={@element_class}
      multiple={@multiple}
      label_position={:below}
    >
      <:label class={slot_attr(@label, :class, "")}>
        {render_slot(@label)}
      </:label>
      <input type="checkbox" id={@field.id} name={@name} value={@value} checked={@checked} />
    </.element>
    """
  end

  def hidden(assigns) do
    name = multiple_name(assigns)
    assigns = assign(assigns, :name, name)

    ~H"""
    <input type="hidden" id={@field.id} name={@name} value={@value} />
    """
  end

  defp multiple_name(%{multiple: true, field: field}), do: field.name <> "[]"
  defp multiple_name(%{multiple: true, name: name}), do: name <> "[]"
  defp multiple_name(%{field: field}), do: field.name
  defp multiple_name(%{name: name}), do: name

  attr(:form, :any, default: nil)
  attr(:class, :string, default: "py-1.5 pr-20")
  attr(:element_class, :string, default: "")
  attr(:name, :atom)
  attr(:field, :any)
  attr(:autocomplete, :string, default: "")
  attr(:disabled, :boolean, default: false)
  attr(:rest, :global)
  attr(:type, :string, default: "text")

  slot(:label, required: false) do
    attr(:class, :string, required: false)
  end

  @class "pl-2 block w-full bg-gray-100 rounded border-0 text-gray-900 ring-1 ring-inset ring-gray-500 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-pink-600 sm:text-sm sm:leading-6 group-[.has-errors]:ring-red-400 disabled:bg-gray-150 disabled:border-gray-300 text-gray-500"
  def text_input(%{field: _field} = assigns) do
    assigns = update(assigns, :class, &Box.Html.class(@class, &1))

    ~H"""
    <.element name={@field.name} errors={@field.errors} class={@element_class}>
      <:label class={slot_attr(@label, :class, "")}>
        {render_slot(@label)}
      </:label>
      <input
        type={@type}
        id={@field.id}
        name={@field.name}
        value={@field.value}
        class={@class}
        disabled={@disabled}
        autocomplete={@autocomplete}
        onkeyup="event.preventDefault()"
        {@rest}
      />
    </.element>
    """
  end

  attr(:form, :any, default: nil)
  attr(:class, :string, default: "")
  attr(:element_class, :string, default: "flex flex-row")
  attr(:name, :atom)
  attr(:field, :any)
  attr(:value, :any, required: true)
  attr(:disabled, :boolean, default: false)
  attr(:rest, :global)

  slot(:label, required: false) do
    attr(:class, :string, required: false)
  end

  def radio_input(assigns) do
    ~H"""
    <.element name={@field.name} errors={@field.errors} class={@element_class} label_position={:below}>
      <input
        type="radio"
        id={@field.id}
        name={@field.name}
        checked={@value == (@field.value || "")}
        value={@value}
        class={@class}
        disabled={@disabled}
        {@rest}
      />
      <:label class={slot_attr(@label, :class, "")}>
        {render_slot(@label)}
      </:label>
    </.element>
    """
  end

  attr(:type, :atom, default: :button)
  attr(:style, :atom, default: :default)
  attr(:size, :atom, default: :normal)
  attr(:class, :string, default: "")
  attr(:href, :string)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  @default_classes "inline-block rounded"
  @styles %{
    default: "bg-pink-500 hover:bg-pink-600 text-gray-50",
    danger: "bg-red-500 hover:bg-red-600 text-gray-50",
    white: "bg-gray-100 text-gray-900 hover:bg-gray-200",
    clear: "bg-transparent text-gray-200 hover:text-pink-400",
    link: "bg-transparent text-pink-600 hover:text-pink-400",
    outline:
      "bg-transparent text-pink-500 border border-pink-500 hover:bg-pink-600 hover:border-pink-600 hover:text-white disabled:bg-gray-400 disabled:hover:bg-gray-400 disabled:text-gray-700 disabled:hover:text-gray-700 disabled:border-gray-400 disabled:hover:border-gray-400"
  }
  @sizes %{
    small: "py-1 px-2 h-8",
    normal: "py-1.5 px-3 h-10"
  }
  def button(%{href: _href} = assigns) do
    assigns = update_button_class(assigns)

    ~H"""
    <.link patch={@href} class={@class} {@rest}>
      {render_slot(@inner_block)}
    </.link>
    """
  end

  def button(assigns) do
    assigns = update_button_class(assigns)

    ~H"""
    <button type={@type} class={@class} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr(:errors, :list)

  def field_errors(assigns) do
    ~H"""
    <%= if is_list(@errors) and Enum.any?(@errors) do %>
      <div class="flex flex-col text-sm text-right text-red-400">
        <%= for error <- @errors do %>
          <span>{Box.Ecto.Changeset.format_error(error, gettext: IvhsBrokerWeb.Gettext)}</span>
        <% end %>
      </div>
    <% end %>
    """
  end

  @button_styles ~w(style size)a
  defp update_button_class(assigns) do
    style_class =
      Enum.reduce(@button_styles, @default_classes, fn button_style, acc ->
        style_class = style_class(assigns, button_style)
        Box.Html.class(acc, style_class)
      end)

    update(assigns, :class, fn class ->
      Box.Html.class(style_class, class)
    end)
  end

  defp style_class(assigns, :style), do: Map.fetch!(@styles, Map.fetch!(assigns, :style))
  defp style_class(assigns, :size), do: Map.fetch!(@sizes, Map.fetch!(assigns, :size))

  defp slot_attr([], _key, default), do: default
  defp slot_attr([item | _], key, default), do: Map.get(item, key, default)
end
