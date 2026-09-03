defmodule IvhsBroker.Schema.Card.Target.YoutubeTest do
  use IvhsBroker.DataCase

  alias IvhsBroker.Schema.Card.Target.Youtube

  @fixture "./test/support/fixtures/youtube/embed.json"
  @fixture_body @fixture |> File.read!() |> JSON.decode!()

  @code "J1WoNuemKOg"
  @url "https://www.youtube.com/watch?v=#{@code}"

  describe "changeset/2" do
    setup [:mock_http]

    test "casts a video code " do
      assert %Ecto.Changeset{valid?: true, changes: %{code: @code}} =
               Youtube.changeset(%Youtube{}, %{code: @code})
    end

    test "casts a video uri" do
      assert %Ecto.Changeset{valid?: true, changes: %{code: @code}} =
               Youtube.changeset(%Youtube{}, %{code: @url})
    end

    test "casts video details if valid code" do
      assert %Ecto.Changeset{valid?: true, changes: %{code: @code, author_name: "Veritasium"}} =
               Youtube.changeset(%Youtube{}, %{code: @url})
    end

    @tag http_status: 404, http_body: "Not found"
    test "fails silently if video cannot be fetched" do
      assert %Ecto.Changeset{valid?: true, changes: %{code: @code} = changes} =
               Youtube.changeset(%Youtube{}, %{code: @url})

      refute Map.has_key?(changes, :author_name)
    end
  end

  defp mock_http(context) do
    status = Map.get(context, :http_status, 200)
    body = Map.get(context, :http_body, @fixture_body)

    Mox.expect(IvhsBroker.HttpMock, :request, fn _request, _options ->
      {:ok, %Box.Http.Response{status: status, body: body, headers: []}}
    end)

    :ok
  end
end
