defmodule IvhsBrokerWeb.Components.Form do
  use IvhsBrokerWeb, :component

  attr(:field, :map)
  attr(:label, :string)
  attr(:items, :list)

  def selector(assigns) do
    ~H"""
    <fieldset class="space-y-2">
      <legend class="text-[10px] font-black uppercase tracking-[0.18em]">
        {@label}
      </legend>

      <div class="inline-flex border-2 border-ink">
        <%= for {key, label} <- @items do %>
          <label class="cursor-pointer">
            <input
              type="radio"
              name={@field.name}
              value={key}
              checked={@field.value == key}
              class="peer sr-only"
            />

            <span class={
              Box.Html.class(
                "block font-black peer-focus-visible:outline-2 peer-focus-visible:outline-ink peer-focus-visible:outline-offset-2 px-5 py-2.5 text-xs uppercase",
                [
                  {@field.value == key, "bg-ink border-ink border-r-2 text-paper",
                   "bg-paper hover:bg-surface peer-checked:bg-ink peer-checked:text-paper"}
                ]
              )
            }>
              {label}
            </span>
          </label>
        <% end %>
      </div>
    </fieldset>
    """
  end

  attr(:field, :map)
  attr(:label, :string, default: nil)
  attr(:placeholder, :string, default: "")

  def input(assigns) do
    ~H"""
    <div class="space-y-2">
      <%= if @label do %>
        <label for={@field.name} class="block text-[10px] font-black uppercase tracking-[0.18em] mt-3">
          {@label}
        </label>
      <% end %>
      <input
        name={@field.name}
        type="text"
        placeholder={@placeholder}
        value={@field.value}
        class="w-full border-2 border-ink bg-paper px-3 py-2.5 font-mono text-sm outline-none transition focus:bg-white focus:shadow-[3px_3px_0_#25251f]"
      />
    </div>
    """
  end

  slot(:inner_block)
  attr(:type, :string, default: "submit")
  attr(:style, :atom, default: :success)
  attr(:on_click, :string, default: "")

  @styles %{
    action: "bg-white",
    success: "bg-success"
  }

  def button(assigns) do
    assigns = assign(assigns, :style, @styles[assigns.style])

    ~H"""
    <button
      type={@type}
      phx-click={@on_click}
      class={
        Box.Html.class(
          "border-2 border-ink px-5 py-3 text-xs font-black uppercase tracking-wider shadow-[4px_4px_0_#25251f] transition hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0_#25251f]",
          [@style]
        )
      }
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  slot(:inner_block)

  def button_row(assigns) do
    ~H"""
    <div class="flex flex-col-reverse gap-3 border-t-2 border-ink pt-3 mt-2 sm:flex-row sm:justify-end">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr(:field, :map)
  attr(:label, :string)
  attr(:rows, :integer, default: 4)
  attr(:placeholder, :string, default: "")

  def textarea(assigns) do
    ~H"""
    <div class="space-y-2 mt-3">
      <label for={@field.name} class="block text-[10px] font-black uppercase tracking-[0.18em]">
        {@label}
      </label>
      <textarea
        name={@field.name}
        rows={@rows}
        placeholder={@placeholder}
        class="w-full resize-y border-2 border-ink bg-paper px-3 py-2.5 font-mono text-sm outline-none focus:bg-white focus:shadow-[3px_3px_0_#25251f]"
      >{@field.value}</textarea>
    </div>
    """
  end

  attr(:field, :map)
  attr(:placeholder, :string, default: "")

  def search(assigns) do
    ~H"""
    <div class="relative mt-3">
      <label class="sr-only" for={@field.name}>{@placeholder}</label>
      <input
        type="search"
        name={@field.name}
        value={@field.value}
        placeholder={@placeholder}
        class="w-full border-2 border-ink bg-paper py-2.5 px-3 font-mono text-sm outline-none placeholder:text-ink/40 focus:bg-white focus:shadow-[3px_3px_0_#25251f]"
      />
    </div>
    """
  end
end
