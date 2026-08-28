defmodule IvhsBroker.Schema.Card do
  use IvhsBroker, :schema

  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead

  @primary_key {:uid, :string, autogenerate: false}
  schema("cards") do
    field(:label, :string)

    has_many(:card_reads, CardRead,
      foreign_key: :card_uid,
      preload_order: [desc: :inserted_at]
    )

    timestamps()
  end

  @required ~w(uid)a

  def create_changeset(%Card{} = card \\ %Card{}, params) do
    card
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
    |> validate_uid(:uid)
  end

  @optional ~w(label)a
  def update_changeset(%Card{} = card, params) do
    card
    |> Ecto.Changeset.cast(params, @optional)
    |> validate_label()
  end

  defp validate_label(%Ecto.Changeset{valid?: true} = changeset) do
    case Ecto.Changeset.get_change(changeset, :label) do
      nil ->
        changeset

      label ->
        if label == Ecto.Changeset.get_field(changeset, :uid) or label == "" do
          Ecto.Changeset.put_change(changeset, :label, nil)
        else
          changeset
        end
    end
  end

  def validate_uid(%Ecto.Changeset{} = changeset, field) do
    changeset
    |> Ecto.Changeset.update_change(field, &String.upcase/1)
    |> Ecto.Changeset.validate_format(field, ~r/^[A-F0-9]+$/)
  end

  def label(%Card{label: label}) when is_binary(label), do: label
  def label(%Card{uid: uid}), do: uid
end
