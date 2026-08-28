defmodule IvhsBroker.CardReads do
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Repo

  require Ecto.Query

  def list_card_reads(params) do
    params = Map.put_new(params, :sort_by, {:desc, :inserted_at})

    CardRead
    |> Ecto.Query.order_by([cr], {:desc, cr.inserted_at})
    |> Repo.paginate(params)
  end

  def count_card_reads do
    Box.Cache.memoize(IvhsBroker.Cache, :count_card_reads, fn ->
      Repo.aggregate(CardRead, :count)
    end)
  end
end
