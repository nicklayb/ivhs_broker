defmodule IvhsBroker.Cards do
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Repo

  require Ecto.Query

  def list_cards(params) do
    params = Map.put_new(params, :sort_by, :uid)

    Card
    |> Ecto.Query.order_by([c], {:desc, c.updated_at})
    |> Repo.paginate(params)
  end
end
