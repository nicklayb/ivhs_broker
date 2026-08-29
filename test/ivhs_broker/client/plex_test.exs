defmodule IvhsBroker.Client.PlexTest do
  use IvhsBroker.DataCase

  alias IvhsBroker.Client.Plex

  setup [
    :verify_on_exit!,
    :setup_env
  ]

  @plex_host "http://plex:32400"

  describe "search/2" do
    test "converts xml to maps" do
      Mox.expect(IvhsBroker.HttpMock, :request, fn _request, _options ->
        body = File.read!("./test/support/fixtures/plex/search.xml")
        {:ok, %Box.Http.Response{status: 200, body: body, headers: []}}
      end)

      assert {:ok,
              %{
                videos: [
                  %{
                    type: "movie",
                    title: "Cars",
                    grandparent_title: "",
                    parent_title: "",
                    rating_key: "2195",
                    library_id: "4",
                    library_title: "Enfants",
                    art: @plex_host <> "/library/metadata/2195/thumb/1784881869"
                  },
                  %{
                    type: "movie",
                    title: "Cars 3",
                    grandparent_title: "",
                    parent_title: "",
                    rating_key: "142951",
                    library_id: "4",
                    library_title: "Enfants",
                    art: @plex_host <> "/library/metadata/142951/thumb/1785136932"
                  },
                  %{
                    type: "movie",
                    title: "Cars 2",
                    grandparent_title: "",
                    parent_title: "",
                    rating_key: "142920",
                    library_id: "4",
                    library_title: "Enfants",
                    art: @plex_host <> "/library/metadata/142920/thumb/1785136932"
                  },
                  %{
                    type: "episode",
                    title: "La fièvre de la vitesse",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146045",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Le mariage",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146051",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "La légende",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146046",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Extinction des phares",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146044",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Des ennuis sur la route",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146050",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Film de série B",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146049",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Le dino-parc",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146043",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Les camions",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146048",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title: "Que le spectacle commence",
                    grandparent_title: "Cars : Sur la route",
                    parent_title: "Season 1",
                    rating_key: "146047",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/146041/thumb/1785572565"
                  },
                  %{
                    type: "episode",
                    title:
                      "Clés à chocs pneumatiques, éviers en marbre de culture, chips de plantain, stock-cars",
                    grandparent_title: "Comment c'est fait",
                    parent_title: "Season 12",
                    rating_key: "126507",
                    library_id: "2",
                    library_title: "Série télé",
                    art: @plex_host <> "/library/metadata/126440/thumb/1787989481"
                  }
                ]
              }} = Plex.search("Cars")
    end
  end

  defp setup_env(_context) do
    Box.Test.MockConfig.mock_config(:ivhs_broker, IvhsBroker.Client.Plex, host: @plex_host)
    :ok
  end
end
