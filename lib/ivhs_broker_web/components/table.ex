defmodule IvhsBrokerWeb.Components.Table do
  use IvhsBrokerWeb, :component

  def render(%{data: %Phoenix.LiveView.AsyncResult{}} = assigns) do
    ~H"""
    <.render {assigns} data={@data.result} />
    """
  end

  def render(%{data: %Box.Ecto.Pagination.Page{}} = assigns) do
    ~H"""
    <div>
      <.render {assigns} data={@data.results} />
      <.pagination page={@data} />
    </div>
    """
  end

  def render(%{data: data} = assigns) when is_list(data) do
    titles = Enum.map(assigns.cell, &%{title: &1.title, class: Map.get(&1, :header_class, "")})

    assigns = assign(assigns, :titles, titles)

    ~H"""
    <table class="w-full min-w-[720px] border-collapse text-left">
      <thead>
        <tr class="border-b-2 border-[#25251f] bg-[#e7dcc5]">
          <%= for %{title: title, class: class} <- @titles do %>
            <th class={
              Box.Html.class("px-3 py-3 text-[10px] font-black uppercase tracking-[0.18em]", class)
            }>
              {title}
            </th>
          <% end %>
        </tr>
      </thead>

      <tbody class="divide-y-2 divide-[#25251f]">
        <%= for row <- @data do %>
          <tr class="group hover:bg-[#f3ead8] animate-new-item">
            <%= for cell <- @cell do %>
              <td class={Box.Html.class("px-3 py-2", Map.get(cell, :cell_class, ""))}>
                {render_slot(cell, row)}
              </td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def pagination(assigns) do
    assigns =
      assigns
      |> assign(:has_next_page, assigns.page.has_next_page)
      |> assign(:has_prev_page, assigns.page.offset > 0)

    ~H"""
    <div class="flex flex-col gap-3 border-t-2 border-[#25251f] p-4 sm:flex-row sm:items-center sm:justify-between">
      <div class="font-mono text-xs text-[#8b8576]">
        {gettext("Showing")}
        <strong class="text-[#25251f]">
          {@page.offset + 1}–{@page.offset + length(@page.results)}
        </strong>
      </div>

      <div class="flex">
        <.pagination_button on_click="prev-page" disabled={not @has_prev_page}>
          ← {gettext("Prev")}
        </.pagination_button>
        <.pagination_button on_click="next-page" disabled={not @has_next_page}>
          {gettext("Next")} →
        </.pagination_button>
      </div>
    </div>
    """
  end

  defp pagination_button(assigns) do
    ~H"""
    <button
      phx-click={@on_click}
      class={
        Box.Html.class(
          "border-2 bg-[#e7dcc5] px-4 py-2 text-xs font-black uppercase",
          [
            {
              not @disabled,
              "border-[#25251f] hover:bg-[#25251f] hover:text-[#f3ead8]",
              "text-gray-500 border-gray-500 disabled:bg-paper"
            }
          ]
        )
      }
      disabled={@disabled}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
