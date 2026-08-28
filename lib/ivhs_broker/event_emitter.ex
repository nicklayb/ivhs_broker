defmodule IvhsBroker.EventEmitter do
  use GenServer

  require Logger

  alias IvhsBroker.Schema.CardRead

  alias IvhsBroker.Mqtt.Client, as: MqttClient

  @default_name __MODULE__

  @debounce_timer :timer.seconds(3)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Keyword.get(args, :name, @default_name))
  end

  def init(_args) do
    IvhsBroker.PubSub.subscribe("card_reads")
    {:ok, %{timer: nil}}
  end

  @medias %{
    "047F1A7ED52A81" => "Toy Story",
    "04289161D12A81" => "Cars",
    "04F94B73D42A81" => "Moana"
  }

  def handle_info({:publish, topic, payload}, state) do
    with {:error, _} = error <- MqttClient.publish(topic, JSON.encode!(payload), []) do
      Logger.error("[#{inspect(__MODULE__)}] [error] #{inspect(error)}")
    end

    {:noreply, %{state | timer: nil}}
  end

  def handle_info(
        %Box.PubSub.Message{
          topic: "card_reads",
          message: :new_entry,
          params: %CardRead{card_uid: uid, state: card_state} = card_read
        },
        state
      )
      when is_map_key(@medias, uid) do
    Logger.info(
      "[#{inspect(__MODULE__)}] [emit] [card: #{card_read.card_uid}] [device: #{card_read.device_reader_name}] #{card_state}"
    )

    media = Map.get(@medias, card_read.card_uid)

    state =
      case {state.timer, card_state} do
        {nil, :inserted} ->
          Logger.debug("[#{inspect(__MODULE__)}] inserted")

          timer =
            Process.send_after(
              self(),
              {:publish, "ivhs/start", %{library: "Enfants", media: media, media_type: "MOVIE"}},
              @debounce_timer
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
end
