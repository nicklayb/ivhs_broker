defmodule IvhsBroker.Mqtt.Adapter.Mqttx do
  @behaviour IvhsBroker.Mqtt.Adapter

  @base_options [
    await_connect: true
  ]

  @impl IvhsBroker.Mqtt.Adapter
  def connect(options) do
    @base_options
    |> Keyword.merge(options)
    |> MqttX.Client.connect()
  end

  @impl IvhsBroker.Mqtt.Adapter
  def child_spec(_options) do
    %{}
  end

  @impl IvhsBroker.Mqtt.Adapter
  def disconnect(client) do
    MqttX.Client.disconnect(client)
  end

  @impl IvhsBroker.Mqtt.Adapter
  def publish(client, topic, payload, options) do
    publish_options = Keyword.get(options, :publish_options, [])
    MqttX.Client.publish(client, topic, payload, publish_options)
  end

  @impl IvhsBroker.Mqtt.Adapter
  def subscribe(client, topic, options) do
    subscribe_options = Keyword.get(options, :subscribe_options, [])
    MqttX.Client.subscribe(client, topic, subscribe_options)
  end
end
