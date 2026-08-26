defmodule IvhsBroker.Repo.Migrations.CreateCardReadsTable do
  use Ecto.Migration

  @indexes [
    card_reads: [
      [:device_reader_name],
      [:card_uid],
      [:device_reader_name, :card_uid]
    ]
  ]

  def up do
    execute("CREATE TYPE card_read_state AS ENUM ('inserted', 'removed');")

    create table(:card_reads) do
      add(
        :device_reader_name,
        references(:devices, on_delete: :delete_all, column: :reader_name, type: :text),
        null: false
      )

      add(:card_uid, references(:cards, on_delete: :delete_all, column: :uid, type: :text),
        null: false
      )

      add(:state, :card_read_state, null: false)

      timestamps()
    end

    apply_indexes(&create/1)
  end

  def down do
    apply_indexes(&drop_if_exists/1)

    drop_if_exists(table(:card_reads))

    execute("DROP TYPE IF EXISTS card_read_state")
  end

  defp apply_indexes(function) do
    for {table, indexes} <- @indexes do
      for columns <- indexes, do: function.(index(table, columns))
    end
  end
end
