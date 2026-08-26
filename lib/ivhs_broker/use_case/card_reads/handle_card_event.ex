defmodule IvhsBroker.UseCase.CardReads.HandleCardEvent do
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead
  use IvhsBroker.UseCase

  @impl Box.UseCase
  def validate(params, _options) do
    changeset = validate_params(params)

    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  @types %{
    reader_name: :string,
    uid: :string,
    state: Ecto.ParameterizedType.init(Ecto.Enum, values: CardRead.states())
  }
  @type_keys Map.keys(@types)
  def validate_params(params) do
    {%{}, @types}
    |> Ecto.Changeset.cast(params, @type_keys)
    |> Ecto.Changeset.validate_required(@type_keys)
  end

  @impl Box.UseCase
  def run(multi, %{reader_name: reader_name, uid: uid, state: state}, _options) do
    multi
    |> Ecto.Multi.run(:get_or_create_device, fn repo, _ ->
      with nil <- repo.get(Device, reader_name) do
        %{reader_name: reader_name}
        |> Device.create_changeset()
        |> repo.insert()
      end

      {:ok, reader_name}
    end)
    |> Ecto.Multi.run(:get_or_create_card, fn repo, _ ->
      with nil <- repo.get(Card, uid) do
        %{uid: uid}
        |> Card.create_changeset()
        |> repo.insert()
      end

      {:ok, uid}
    end)
    |> Ecto.Multi.insert(
      :card_read,
      CardRead.create_changeset(%{card_uid: uid, device_reader_name: reader_name, state: state})
    )
  end

  @impl Box.UseCase
  def return(%{card_read: card_read}, _options) do
    card_read
  end
end
