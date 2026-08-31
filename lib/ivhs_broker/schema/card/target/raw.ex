defmodule IvhsBroker.Schema.Card.Target.Raw do
  use IvhsBroker.Schema.Card.Target

  alias IvhsBroker.Schema.Card.Target.Raw

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

  @impl IvhsBroker.Schema.Card.Target
  def to_payload(%Raw{} = raw) do
    %{
      media_content_id: raw.payload,
      media_content_type: raw.content_type
    }
  end
end
