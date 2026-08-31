defmodule IvhsBroker.Schema.Card.Target.Youtube do
  use IvhsBroker.Schema.Card.Target

  alias IvhsBroker.Schema.Card.Target.Youtube

  embedded_schema do
    field(:code, :string)
  end

  @required ~w(code)a
  def changeset(%Youtube{} = youtube, params) do
    youtube
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
    |> maybe_extract_code()
  end

  defp maybe_extract_code(%Ecto.Changeset{} = changeset) do
    with code when is_binary(code) <- Ecto.Changeset.get_change(changeset, :code),
         true <- uri?(code) do
      extract_code(changeset, code)
    else
      _ -> changeset
    end
  end

  defp extract_code(%Ecto.Changeset{} = changeset, uri) do
    %URI{query: query} = URI.parse(uri)

    %{"v" => video_code} = URI.decode_query(query)

    Ecto.Changeset.put_change(changeset, :code, video_code)
  rescue
    _ ->
      Ecto.Changeset.add_error(changeset, :code, "is invalid")
  end

  defp uri?(code) do
    Regex.match?(~r/https?:\/\/.*/, code)
  end

  def thumbnail(code) do
    "https://img.youtube.com/vi/#{code}/0.jpg"
  end

  def video_url(code) do
    "https://youtube.com/watch?v=#{code}"
  end

  @impl IvhsBroker.Schema.Card.Target
  def to_payload(%Youtube{} = youtube) do
    %{
      media_content_id: JSON.encode!(%{app_name: "youtube", media_id: youtube.code}),
      media_content_type: "cast"
    }
  end
end
