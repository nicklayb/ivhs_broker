defmodule IvhsBroker.Schema.Card.Target.Raw do
  use IvhsBroker, :schema

  alias IvhsBroker.Schema.Card.Target.Raw

  @primary_key false

  embedded_schema do
    field(:content_type, :string)
    field(:payload, :string)
  end

  @required ~w(content_type payload)a
  def changeset(%Raw{} = raw, params) do
    raw
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
  end
end
