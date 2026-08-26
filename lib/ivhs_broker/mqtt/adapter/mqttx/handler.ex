defmodule IvhsBroker.Mqtt.Adapter.Mqttx.Handler do
  require Logger
  alias IvhsBroker.CardConsumer.UpdatedMessage

  def handle_mqtt_event(:message, {topic, payload, _packet}, state) do
    Logger.debug("[#{inspect(__MODULE__)}] [#{to_topic_string(topic)}] #{inspect(payload)}")

    if topic == ["ivhs", "card"] do
      with {:ok, json} <- JSON.decode(payload),
           {:ok, %UpdatedMessage{} = message} <- UpdatedMessage.init(json) do
        Logger.debug("[#{inspect(__MODULE__)}] [handle]")
        IvhsBroker.CardConsumer.handle(message)
      else
        error ->
          Logger.error("[#{inspect(__MODULE__)}] [error] #{inspect(error)}")
      end
    end

    state
  end

  def handle_mqtt_event(:connected, _data, state) do
    Logger.debug("[#{inspect(__MODULE__)}] connected")
    state
  end

  def handle_mqtt_event(:disconnected, reason, state) do
    Logger.debug("[#{inspect(__MODULE__)}] [disconnected] [#{inspect(reason)}]")
    state
  end

  defp to_topic_string(parts), do: Enum.join(parts, "/")
end
