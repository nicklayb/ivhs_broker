defmodule IvhsBroker.Cards do
  alias Box.Ecto.Pagination.Page
  alias IvhsBroker.Cards.Filter, as: CardsFilter
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Repo

  require Ecto.Query

  def list_cards(options) do
    pagination =
      options
      |> Keyword.get(:pagination, %{})
      |> Map.put_new(:sort_by, :uid)

    filter = Keyword.get(options, :filter, CardsFilter.new())

    Card
    |> Ecto.Query.order_by([c], {:desc, c.updated_at})
    |> CardsFilter.apply_filter(filter)
    |> Repo.paginate(pagination)
    |> Page.map_every_results(&preload_card_read/1)
  end

  def get_card(uid) do
    Card
    |> Repo.fetch(uid)
    |> Box.Result.map(&preload_card_read/1)
  end

  def preload_card_read(%Card{} = card) do
    card_reads_query =
      CardRead
      |> Ecto.Query.order_by([cr], {:desc, cr.inserted_at})
      |> Ecto.Query.limit(1)

    Repo.preload(card, card_reads: card_reads_query)
  end

  def count_cards do
    Box.Cache.memoize(IvhsBroker.Cache, :count_cards, fn ->
      Repo.aggregate(Card, :count)
    end)
  end
end
