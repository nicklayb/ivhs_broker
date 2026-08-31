defmodule IvhsBrokerWeb.Cards.Show.Target.Plex do
  use IvhsBrokerWeb, :component

  alias IvhsBroker.Schema.Card.Target

  def render(assigns) do
    assigns =
      assign(
        assigns,
        :plex_currently_selected?,
        Map.get(assigns.currently_selected || %{}, :__struct__) == Target.Plex
      )

    ~H"""
    <div>
      <%= if @plex_currently_selected? do %>
        <div class="mt-2">
          <span class="block text-[10px] font-black uppercase tracking-[0.18em]">
            {gettext("Selected")}
          </span>
          <div class="flex flex-row mb-3 border-2 border-ink h-18">
            <img src={@currently_selected.cover} />
            <div class="p-2 text-md font-black uppercase tracking-[0.18em]">
              {@currently_selected.title}
            </div>
          </div>
        </div>
      <% end %>
      <Components.Form.search
        placeholder={gettext("Search for media...")}
        field={
          %Phoenix.HTML.FormField{
            id: "plex_search",
            errors: [],
            form: @form,
            field: :plex_search,
            value: @plex_search_value,
            name: "plex_search"
          }
        }
      />
      <div>
        <div>
          <%= for plex_result <- @results do %>
            <.plex_result
              item={plex_result}
              selected={
                @plex_currently_selected? and
                  @currently_selected.rating_key == plex_result.rating_key
              }
              on_click="plex:select"
            />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def plex_result(assigns) do
    ~H"""
    <div
      phx-click={@on_click}
      phx-value-rating_key={@item.rating_key}
      phx-value-title={@item.title}
      phx-value-library={@item.library_title}
      phx-value-cover={@item.art}
      phx-value-__type__="plex"
      class={
        Box.Html.class(
          "flex flex-row my-3 p-2 border-2 border-ink hover:shadow-[3px_3px_0_#25251f]",
          [
            {@selected, "shadow-[3px_3px_0_#25251f] bg-white"}
          ]
        )
      }
    >
      <div class="max-w-32 mr-3">
        <img src={@item.art} />
      </div>
      <div class="flex flex-col text-sm uppercase">
        <div class="text-lg font-black uppercase tracking-[0.18em] mb-2">
          {@item.title}
        </div>
        <div class="flex flex-row">
          <%= if @item.grandparent_title != "" do %>
            <div>{@item.grandparent_title}</div>
          <% end %>
          <%= if @item.parent_title != "" do %>
            <div>{" - " <> @item.parent_title}</div>
          <% end %>
        </div>
        <div>{@item.library_title}</div>
        <div>{@item.type}</div>
      </div>
    </div>
    """
  end
end
