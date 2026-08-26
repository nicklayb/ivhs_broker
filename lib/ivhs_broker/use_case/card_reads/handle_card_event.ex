defmodule IvhsBroker.UseCase.CardReads.HandleCardEvent do
  alias IvhsBroker.CardConsumer.UpdatedMessage
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead
  use IvhsBroker.UseCase

  @impl Box.UseCase
  def validate(%UpdatedMessage{} = message, _options) do
    {:ok, message}
  end

  def validate(params, _options) do
    UpdatedMessage.init(params)
  end

  @impl Box.UseCase
  def run(multi, %UpdatedMessage{reader_name: reader_name, uid: uid, state: state}, _options) do
    multi
    |> Ecto.Multi.run(:device, fn repo, _ ->
      get_or_create(repo, Device, reader_name, &Device.create_changeset/1)
    end)
    |> Ecto.Multi.run(:card, fn repo, _ ->
      get_or_create(repo, Card, uid, &Card.create_changeset/1)
    end)
    |> Ecto.Multi.insert(
      :card_read,
      CardRead.create_changeset(%{card_uid: uid, device_reader_name: reader_name, state: state})
    )
  end

  defp get_or_create(repo, schema, key, changeset_function) do
    case repo.fetch(schema, key) do
      {:error, :not_found} ->
        [primary_key] = schema.__schema__(:primary_key)

        %{primary_key => key}
        |> then(changeset_function)
        |> repo.insert()
        |> Box.Result.map(&{:new, &1})

      {:ok, struct} ->
        {:ok, {:existing, struct}}
    end
  end

  @impl Box.UseCase
  def return(%{card_read: card_read}, _options) do
    card_read
  end

  @impl Box.UseCase
  def after_run(
        %{card: {card_status, card}, device: {device_status, device}, card_read: card_read},
        _
      ) do
    [
      {"cards/#{card.uid}", card_read},
      {"devices/#{device.reader_name}", card_read},
      {"card_reads", card_read}
    ]
    |> maybe_add({"cards", card}, card_status == :new)
    |> maybe_add({"devices", device}, device_status == :new)
    |> Enum.each(fn {topic, payload} ->
      IvhsBroker.PubSub.broadcast(topic, {:new_entry, payload})
    end)
  end

  defp maybe_add(list, topic, true), do: [topic | list]
  defp maybe_add(list, _topic, false), do: list
end
