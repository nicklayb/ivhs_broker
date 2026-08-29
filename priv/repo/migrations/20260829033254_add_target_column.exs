defmodule IvhsBroker.Repo.Migrations.AddTargetColumn do
  use Ecto.Migration

  def change do
    alter(table(:cards)) do
      add(:target, :map)
    end
  end
end
