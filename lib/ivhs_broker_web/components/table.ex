defmodule IvhsBrokerWeb.Components.Table do
  use IvhsBrokerWeb, :component

  def render(assigns) do
    IO.inspect(assigns |> Map.delete(:data))

    titles = Enum.map(assigns.cell, &%{title: &1.title, class: Map.get(&1, :header_class, "")})

    assigns = assign(assigns, :titles, titles)

    ~H"""
    <table class="w-full min-w-[720px] border-collapse text-left">
      <thead>
        <tr class="border-b-2 border-[#25251f] bg-[#e7dcc5]">
          <%= for %{title: title, class: class} <- @titles do %>
            <th class={
              Box.Html.class("px-5 py-3 text-[10px] font-black uppercase tracking-[0.18em]", class)
            }>
              {title}
            </th>
          <% end %>
        </tr>
      </thead>

      <tbody class="divide-y-2 divide-[#25251f]">
        <%= for row <- @data.result do %>
          <tr class="group hover:bg-[#f3ead8]">
            <%= for cell <- @cell do %>
              <td class={Box.Html.class("px-5 py-4", Map.get(cell, :cell_class, ""))}>
                {render_slot(cell, row)}
              </td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
