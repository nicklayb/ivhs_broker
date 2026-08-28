defmodule IvhsBroker.Cards do
  alias Box.Ecto.Pagination.Page
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Repo

  require Ecto.Query

  def list_cards(params) do
    params = Map.put_new(params, :sort_by, :uid)

    Card
    |> Ecto.Query.order_by([c], {:desc, c.updated_at})
    |> Repo.paginate(params)
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

  def update_card(%Card{} = card, attrs) do
    update_card(card.uid, attrs)
  end

  def update_card(uid, attrs) do
    IvhsBroker.UseCase.execute(IvhsBroker.UseCase.Cards.Update, {uid, attrs})
  end
end
