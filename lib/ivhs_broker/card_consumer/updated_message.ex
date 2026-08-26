defmodule IvhsBroker.CardConsumer.UpdatedMessage do
  defstruct [:reader_name, :uid, :state]

  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.CardConsumer.UpdatedMessage

  def init(params) do
    case validate_params(params) do
      %Ecto.Changeset{valid?: false} = changeset -> {:error, changeset}
      changeset -> {:ok, Ecto.Changeset.apply_changes(changeset)}
    end
  end

  @types %{
    reader_name: :string,
    uid: :string,
    state: Ecto.ParameterizedType.init(Ecto.Enum, values: CardRead.states())
  }
  @type_keys Map.keys(@types)
  def validate_params(params) do
    {%UpdatedMessage{}, @types}
    |> Ecto.Changeset.cast(params, @type_keys)
    |> Ecto.Changeset.validate_required(@type_keys)
    |> Card.validate_uid(:uid)
    |> Device.validate_reader_name(:reader_name)
  end
end
