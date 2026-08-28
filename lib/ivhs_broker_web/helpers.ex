defmodule IvhsBrokerWeb.Helpers do
  alias Phoenix.LiveView.AsyncResult

  def map_connected(%Phoenix.LiveView.Socket{} = socket, function) do
    if Phoenix.LiveView.connected?(socket) do
      function.(socket)
    else
      socket
    end
  end

  def subscribe(%Phoenix.LiveView.Socket{} = socket, topic_or_topics, options \\ []) do
    map_connected(socket, fn socket ->
      topics = List.wrap(topic_or_topics)

      if Keyword.get(options, :unsubscribe_removed, true) do
        removed_topics = topics -- subscribed_topics(socket)
        IvhsBroker.PubSub.unsubscribe(removed_topics)
      end

      IvhsBroker.PubSub.subscribe(topics)

      update_topics(socket, fn existing_topics ->
        topics ++ existing_topics
      end)
    end)
  end

  def unsubscribe_all(%Phoenix.LiveView.Socket{} = socket) do
    map_connected(socket, fn socket ->
      socket
      |> subscribed_topics()
      |> IvhsBroker.PubSub.unsubscribe()

      update_topics(socket, fn _ -> [] end)
    end)
  end

  def unsubscribe(%Phoenix.LiveView.Socket{} = socket, topic_or_topics) do
    map_connected(socket, fn socket ->
      topics = List.wrap(topic_or_topics)

      IvhsBroker.PubSub.unsubscribe(topics)

      update_topics(socket, fn existing_topics ->
        existing_topics -- topics
      end)
    end)
  end

  def subscribed_topics(%Phoenix.LiveView.Socket{assigns: assigns}) do
    Map.get(assigns, :__topics__, [])
  end

  def update_async_result(%Phoenix.LiveView.Socket{} = socket, key, function) do
    Phoenix.Component.update(socket, key, fn
      %AsyncResult{ok?: true, loading: nil, result: result} = async_result ->
        %AsyncResult{async_result | result: function.(result)}

      async_result ->
        async_result
    end)
  end

  defp update_topics(%Phoenix.LiveView.Socket{} = socket, function) do
    Phoenix.Component.update(socket, :__topics__, function)
  end

  def assign_observable(%Phoenix.LiveView.Socket{} = socket, observables) do
    Enum.reduce(observables, socket, fn {key, function}, socket ->
      socket
      |> Phoenix.Component.assign(key, function.())
      |> map_connected(fn socket ->
        Box.Cache.observe(IvhsBroker.Cache, key)
        Phoenix.Component.update(socket, :__observables__, &Map.put(&1, key, function))
      end)
    end)
  end
end
