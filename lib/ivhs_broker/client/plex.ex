defmodule IvhsBroker.Client.Plex do
  import SweetXml, only: [sigil_x: 2]

  @default_limit 20

  def search(query, options \\ []) do
    limit = Keyword.get(options, :limit, @default_limit)

    call("/hubs/search", %{query: query, limit: limit},
      videos: [
        ~x"//Video"l,
        art:
          ~x|./Image[@type="coverPoster"]/@url|s
          |> SweetXml.transform_by(&Path.join(config().host, &1)),
        library_title: ~x"./@librarySectionTitle"s,
        library_id: ~x"./@librarySectionID"s,
        rating_key: ~x"./@ratingKey"s,
        title: ~x"./@title"s,
        type: ~x"./@type"s,
        parent_title: ~x"./@parentTitle"s,
        grandparent_title: ~x"./@grandparentTitle"s
      ]
    )
  end

  defp call(url, params, decoder) do
    %{host: host, token: token} = config()

    options =
      maybe_put_token(
        [
          base_url: host,
          url: url,
          params: params
        ],
        token
      )

    with {:ok, _, %Box.Http.Response{body: body}} <- IvhsBroker.Http.request_200(options) do
      {:ok, decode_xml(body, decoder)}
    end
  end

  defp decode_xml(document, pattern) do
    document
    |> SweetXml.parse()
    |> SweetXml.xmap(pattern)
  end

  defp maybe_put_token(options, nil), do: options

  defp maybe_put_token(options, token) do
    header = {"X-Plex-Token", token}
    Keyword.update(options, :headers, [header], &[header | &1])
  end

  defp config do
    config = Application.fetch_env!(:ivhs_broker, __MODULE__)

    %{
      host: Keyword.fetch!(config, :host),
      token: Keyword.fetch!(config, :token)
    }
  end
end
