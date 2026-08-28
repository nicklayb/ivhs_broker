defmodule IvhsBroker.Mqtt.Client do
  def publish(topic, payload, options \\ []) do
    {adapter, adapter_options} = adapter(options)
    adapter.publish(nil, topic, payload, adapter_options)
  end

  def subscribe(topic, options \\ []) do
    {adapter, adapter_options} = adapter(options)
    adapter.subscribe(nil, topic, adapter_options)
  end

  def child_spec(options) do
    connection_options = connection_options(options)
    {adapter, adapter_options} = adapter(connection_options)

    adapter.child_spec(adapter_options)
  end

  defp adapter(extra_options) do
    case Application.fetch_env!(:ivhs_broker, IvhsBroker.Mqtt)[:adapter] do
      {adapter, options} -> {adapter, Keyword.merge(options, extra_options)}
      adapter -> {adapter, extra_options}
    end
  end

  @connection_options ~w(host port username password client_id)a
  def connection_options(extra_options) do
    :ivhs_broker
    |> Application.fetch_env!(IvhsBroker.Mqtt)
    |> Keyword.take(@connection_options)
    |> Keyword.merge(extra_options)
  end
end
