defmodule IvhsBrokerWeb.Helpers do
  alias Phoenix.LiveView.AsyncResult

  def map_connected(%Phoenix.LiveView.Socket{} = socket, function) do
    if Phoenix.LiveView.connected?(socket) do
      function.(socket)
    else
      socket
    end
  end

  def subscribe(%Phoenix.LiveView.Socket{} = socket, topic_or_topics) do
    map_connected(socket, fn socket ->
      topic_or_topics
      |> List.wrap()
      |> IvhsBroker.PubSub.subscribe()

      socket
    end)
  end

  def update_async_result(%Phoenix.LiveView.Socket{} = socket, key, function) do
    Phoenix.Component.update(socket, key, fn
      %AsyncResult{ok?: true, loading: nil, result: result} = async_result ->
        %AsyncResult{async_result | result: function.(result)}

      async_result ->
        async_result
    end)
  end
end
