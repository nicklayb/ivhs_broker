defmodule IvhsBroker.Schema.CardRead do
  use IvhsBroker, :schema

  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Schema.Device

  @states ~w(inserted removed)a

  schema("card_reads") do
    belongs_to(:card, Card, foreign_key: :card_uid, type: :string, references: :uid)

    belongs_to(:device, Device,
      foreign_key: :device_reader_name,
      type: :string,
      references: :reader_name
    )

    field(:state, Ecto.Enum, values: @states)

    timestamps()
  end

  @required ~w(card_uid device_reader_name state)a

  def create_changeset(%CardRead{} = card_read \\ %CardRead{}, params) do
    card_read
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
  end

  def states, do: @states
end
