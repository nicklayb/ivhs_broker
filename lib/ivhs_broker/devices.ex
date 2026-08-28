defmodule IvhsBroker.Devices do
  alias Box.Ecto.Pagination.Page
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Repo

  require Ecto.Query

  def list_devices(params) do
    params = Map.put_new(params, :sort_by, :reader_name)

    Device
    |> Ecto.Query.order_by([d], {:desc, d.updated_at})
    |> Repo.paginate(params)
    |> Page.map_every_results(&preload_card_read/1)
  end

  def get_device(reader_name) do
    Device
    |> Repo.fetch(reader_name)
    |> Box.Result.map(&preload_card_read/1)
  end

  def preload_card_read(%Device{} = device) do
    card_reads_query =
      CardRead
      |> Ecto.Query.order_by([cr], {:desc, cr.inserted_at})
      |> Ecto.Query.limit(1)

    Repo.preload(device, card_reads: card_reads_query)
  end

  def count_devices do
    Box.Cache.memoize(IvhsBroker.Cache, :count_devices, fn ->
      Repo.aggregate(Device, :count)
    end)
  end
end
