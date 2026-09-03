defmodule IvhsBroker.Cards.Filter do
  use Box.DataFilter,
    fields: [
      search: [],
      target: []
    ]

  require Ecto.Query

  @impl Box.DataFilter
  def cast(%Filter{}, :search, ""), do: nil

  def cast(%Filter{}, :search, search) do
    with "" <- String.trim(search) do
      nil
    end
  end

  def cast(%Filter{}, :target, empty) when empty in ["", "none"], do: nil
  def cast(%Filter{}, :target, "without"), do: :without

  def cast(%Filter{}, :target, target) do
    IvhsBroker.Schema.Card
    |> PolymorphicEmbed.types(:target)
    |> Enum.find(&(to_string(&1) == target))
  end

  @impl Box.DataFilter
  def apply(%Filter{}, query, _, ""), do: query
  def apply(%Filter{}, query, _, nil), do: query

  def apply(%Filter{}, query, :search, value) do
    search = "%#{value}%"
    Ecto.Query.where(query, [q], ilike(q.uid, ^search) or ilike(q.label, ^search))
  end

  def apply(%Filter{}, query, :target, :without) do
    Ecto.Query.where(query, [q], is_nil(q.target))
  end

  def apply(%Filter{}, query, :target, target) do
    Ecto.Query.where(query, [q], json_extract_path(q.target, ["__type__"]) == ^target)
  end

  @impl Box.DataFilter
  def to_query(%Filter{}, _, nil), do: :ignore
  def to_query(%Filter{}, :search, search), do: search
  def to_query(%Filter{}, :target, target), do: to_string(target)
  def to_query(%Filter{}, _, _), do: :ignore
end
