defmodule IvhsBroker.Schema.Device do
  use IvhsBroker, :schema

  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Schema.Device

  @primary_key {:reader_name, :string, autogenerate: false}
  schema("devices") do
    has_many(:card_reads, CardRead,
      foreign_key: :device_reader_name,
      preload_order: [desc: :inserted_at]
    )

    timestamps()
  end

  @required ~w(reader_name)a

  def create_changeset(%Device{} = device \\ %Device{}, params) do
    device
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
    |> validate_reader_name(:reader_name)
  end

  def validate_reader_name(%Ecto.Changeset{} = changeset, field) do
    changeset
    |> Ecto.Changeset.update_change(field, &String.downcase/1)
    |> Ecto.Changeset.validate_format(field, ~r/^[a-z0-9_-]+$/)
  end
end
