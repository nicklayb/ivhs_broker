defmodule IvhsBroker.Mqtt.Adapter.Mqttx do
  @behaviour IvhsBroker.Mqtt.Adapter

  @base_options [
    await_connect: true
  ]

  @client IvhsBroker.Mqtt.Adapter.Mqttx.Client

  @impl IvhsBroker.Mqtt.Adapter
  def connect(options) do
    @base_options
    |> Keyword.merge(options)
    |> MqttX.Client.connect()
  end

  @impl IvhsBroker.Mqtt.Adapter
  def child_spec(options) do
    @base_options
    |> Keyword.merge(options)
    |> IvhsBroker.Mqtt.Adapter.Mqttx.Client.child_spec()
  end

  @impl IvhsBroker.Mqtt.Adapter
  def disconnect(_client) do
    @client.disconnect()
  end

  @impl IvhsBroker.Mqtt.Adapter
  def publish(_client, topic, payload, options) do
    publish_options = Keyword.get(options, :publish_options, [])
    @client.publish(topic, payload, publish_options)
  end

  @impl IvhsBroker.Mqtt.Adapter
  def subscribe(_client, topic, options) do
    subscribe_options = Keyword.get(options, :subscribe_options, [])
    @client.subscribe(topic, subscribe_options)
  end
end
