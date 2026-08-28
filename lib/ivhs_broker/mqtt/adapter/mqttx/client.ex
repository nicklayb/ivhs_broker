defmodule IvhsBroker.Mqtt.Adapter.Mqttx.Client do
  use MqttX

  alias IvhsBroker.Mqtt.Adapter.Mqttx.Handler, as: MqttxHandler

  @impl true
  def handle_message(topic, payload, packet, state) do
    state = MqttxHandler.handle_mqtt_event(:message, {topic, payload, packet}, state)
    {:ok, state}
  end

  def handle_connected(info, state) do
    state = MqttxHandler.handle_mqtt_event(:connected, info, state)
    subscribe(["ivhs/card"])
    {:ok, state}
  end

  def handle_disconnected(info, state) do
    state = MqttxHandler.handle_mqtt_event(:disconnected, info, state)
    {:ok, state}
  end
end
