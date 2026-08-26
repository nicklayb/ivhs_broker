defmodule IvhsBroker.Repo.Migrations.CreateCardsTable do
  use Ecto.Migration

  def change do
    create table(:cards, primary_key: false) do
      add(:uid, :text, primary_key: true)

      timestamps()
    end
  end
end
