defmodule IvhsBrokerWeb.Components do
  use IvhsBrokerWeb, :component
  alias Phoenix.LiveView.AsyncResult

  def loading(%{async_result: _} = assigns) do
    ~H"""
    <%= case @async_result do %>
      <% %AsyncResult{loading: loading} when not is_nil(loading) -> %>
        Loading...
      <% %AsyncResult{ok?: true} -> %>
        {render_slot(@inner_block)}
      <% %AsyncResult{} -> %>
        <div>
          {gettext("An error occured")}
        </div>
    <% end %>
    """
  end
end
