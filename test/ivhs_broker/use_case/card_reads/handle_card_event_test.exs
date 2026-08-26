defmodule IvhsBroker.UseCase.CardReads.HandleCardEventTest do
  use IvhsBroker.DataCase

  import Ecto.Query

  alias IvhsBroker.Repo
  alias IvhsBroker.Schema.CardRead
  alias IvhsBroker.Schema.Card
  alias IvhsBroker.Schema.Device

  describe "execute/2" do
    test "executes correctly" do
      uid = "ABCD1234"
      reader_name = "test_reader"
      refute Repo.get(Device, reader_name)
      refute Repo.get(Card, uid)
      assert [] = Repo.all(CardRead)

      assert %CardRead{id: first_id, device_reader_name: ^reader_name, card_uid: ^uid} =
               IvhsBroker.UseCase.execute!(IvhsBroker.UseCase.CardReads.HandleCardEvent, %{
                 uid: uid,
                 reader_name: reader_name,
                 state: :inserted
               })

      assert [%Device{reader_name: ^reader_name}] = Repo.all(Device)
      assert [%Card{uid: ^uid}] = Repo.all(Card)
      assert first_id in Repo.all(from(cr in CardRead, select: cr.id))

      assert %CardRead{id: second_id, device_reader_name: ^reader_name, card_uid: ^uid} =
               IvhsBroker.UseCase.execute!(IvhsBroker.UseCase.CardReads.HandleCardEvent, %{
                 uid: uid,
                 reader_name: reader_name,
                 state: :inserted
               })

      assert [%Device{reader_name: ^reader_name}] = Repo.all(Device)
      assert [%Card{uid: ^uid}] = Repo.all(Card)
      assert [_, _] = results = Repo.all(from(cr in CardRead, select: cr.id))
      assert first_id in results
      assert second_id in results
    end
  end
end
