defmodule IvhsBroker do
  @type schema_or_id(schema) :: schema | Ecto.UUID.t()

  def schema do
    quote do
      use Ecto.Schema
      @type t :: %__MODULE__{}

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end

  def embedded_schema do
    quote do
      use Ecto.Schema
      @type t :: %__MODULE__{}
      @primary_key false
    end
  end

  def use_case do
    quote do
      use IvhsBroker.UseCase
    end
  end

  def task do
    quote do
      @behaviour IvhsBroker.Task
    end
  end

  defmacro __using__(type) do
    apply(__MODULE__, type, [])
  end
end
