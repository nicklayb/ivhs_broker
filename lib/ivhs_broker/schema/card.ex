defmodule IvhsBroker.Schema.Card do
  use IvhsBroker, :schema

  import PolymorphicEmbed, only: [polymorphic_embeds_one: 2]

  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.Card.Target
  alias IvhsBroker.Schema.CardRead

  @primary_key {:uid, :string, autogenerate: false}
  schema("cards") do
    field(:label, :string)

    has_many(:card_reads, CardRead,
      foreign_key: :card_uid,
      preload_order: [desc: :inserted_at]
    )

    polymorphic_embeds_one(:target,
      types: [
        raw: Target.Raw,
        plex: Target.Plex
      ],
      on_type_not_found: :changeset_error,
      on_replace: :update
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

  def target_changeset(%Card{} = card, params) do
    card
    |> Ecto.Changeset.cast(params, [])
    |> PolymorphicEmbed.cast_polymorphic_embed(:target)
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

  def to_payload(%Card{target: nil}) do
    nil
  end

  def to_payload(%Card{target: %module{} = struct}) do
    module.to_payload(struct)
  end
end
