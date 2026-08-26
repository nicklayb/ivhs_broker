defmodule IvhsBroker.Schema.Card do
  use IvhsBroker, :schema

  alias IvhsBroker.Schema.Card

  @primary_key {:uid, :string, autogenerate: false}
  schema("cards") do
    timestamps()
  end

  @required ~w(uid)a

  def create_changeset(%Card{} = card \\ %Card{}, params) do
    card
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
    |> validate_uid(:uid)
  end

  def validate_uid(%Ecto.Changeset{} = changeset, field) do
    changeset
    |> Ecto.Changeset.update_change(field, &String.upcase/1)
    |> Ecto.Changeset.validate_format(field, ~r/^[A-F0-9]+$/)
  end
end
