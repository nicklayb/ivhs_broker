defmodule IvhsBroker.EventEmitter do
  use GenServer

  require Logger

  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead

  alias IvhsBroker.Mqtt.Client, as: MqttClient

  @default_name __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Keyword.get(args, :name, @default_name))
  end

  def init(_args) do
    IvhsBroker.PubSub.subscribe("card_reads")
    {:ok, %{timer: nil}}
  end

  def handle_info({:publish, topic, payload}, state) do
    case MqttClient.publish(topic, JSON.encode!(payload), []) do
      {:error, _} = error ->
        Logger.error("[#{inspect(__MODULE__)}] [error] #{inspect(error)}")

      :ok ->
        Logger.info("[#{inspect(__MODULE__)}] [published] #{inspect(payload)}")
    end

    {:noreply, %{state | timer: nil}}
  end

  def handle_info(
        %Box.PubSub.Message{
          topic: "card_reads",
          message: :new_entry,
          params: %CardRead{card: %Card{target: %_{}} = card, state: card_state} = card_read
        },
        state
      ) do
    Logger.info(
      "[#{inspect(__MODULE__)}] [emit] [card: #{card_read.card_uid}] [device: #{card_read.device_reader_name}] #{card_state}"
    )

    state =
      case {state.timer, card_state} do
        {nil, :inserted} ->
          Logger.debug("[#{inspect(__MODULE__)}] inserted")

          payload = Card.to_payload(card)

          timer =
            Process.send_after(
              self(),
              {:publish, "ivhs/start", payload},
              debounce_timer()
            )

          %{state | timer: timer}

        {timer, :removed} ->
          Logger.debug("[#{inspect(__MODULE__)}] removed")
          send(self(), {:publish, "ivhs/stop", %{}})
          if is_reference(timer), do: Process.cancel_timer(timer)
          %{state | timer: nil}

        {timer, _} when is_reference(timer) ->
          Logger.debug("[#{inspect(__MODULE__)}] debounced")
          Process.cancel_timer(timer)
          %{state | timer: nil}
      end

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp debounce_timer do
    :ivhs_broker
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:debounce_timer)
  end
end
