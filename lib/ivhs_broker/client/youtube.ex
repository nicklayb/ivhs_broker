defmodule IvhsBroker.Client.Youtube do
  def embed(code) do
    query = URI.encode_query(%{format: "json", url: "https://youtube.com/watch?v=#{code}"})

    uri = %URI{URI.parse("https://www.youtube.com/oembed") | query: query}

    with {:ok, _, %Box.Http.Response{body: body}} <- IvhsBroker.Http.request_200(url: uri) do
      File.write!("out.json", JSON.encode!(body))
      {:ok, body}
    end
  end
end
