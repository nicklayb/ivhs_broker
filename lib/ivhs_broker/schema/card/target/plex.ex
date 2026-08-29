defmodule IvhsBroker.Schema.Card.Target.Plex do
  use IvhsBroker, :schema

  alias IvhsBroker.Schema.Card.Target.Plex

  @primary_key false

  embedded_schema do
    field(:library, :string)
    field(:rating_key, :string)
    field(:title, :string)
    field(:cover, :string)
  end

  @required ~w(library rating_key title cover)a
  def changeset(%Plex{} = plex, params) do
    plex
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
  end

  def content_type, do: "movie"

  def from_api_result(%{
        title: title,
        library_title: library_title,
        art: art,
        rating_key: rating_key,
        parent_title: parent_title,
        grandparent_title: grandprant_title
      }) do
    title =
      [grandprant_title, parent_title, title]
      |> Enum.reject(&(&1 in ["", nil]))
      |> Enum.join(" - ")

    %{
      title: title,
      cover: art,
      library: library_title,
      rating_key: rating_key
    }
  end
end
