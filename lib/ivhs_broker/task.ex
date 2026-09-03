defmodule IvhsBroker.Task do
  @callback run(Keyword.t()) :: {:ok, any()} | {:error, any()}

  def sync(task, params) do
    task.run(params)
  end
end
