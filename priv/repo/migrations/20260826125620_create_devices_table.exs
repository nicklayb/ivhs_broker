defmodule IvhsBroker.Repo.Migrations.CreateDevicesTable do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add(:reader_name, :text, primary_key: true)

      timestamps()
    end
  end
end
