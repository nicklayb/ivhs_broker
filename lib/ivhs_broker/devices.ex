defmodule IvhsBroker.Devices do
  alias IvhsBroker.Schema.Device
  alias IvhsBroker.Repo

  require Ecto.Query

  def list_devices(params) do
    params = Map.put_new(params, :sort_by, :reader_name)

    Device
    |> Ecto.Query.order_by([d], {:desc, d.updated_at})
    |> Repo.paginate(params)
  end
end
