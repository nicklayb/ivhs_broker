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

      assert {:ok, %CardRead{id: first_id, device_reader_name: ^reader_name, card_uid: ^uid}} =
               execute(%{
                 uid: uid,
                 reader_name: reader_name,
                 state: :inserted
               })

      assert [%Device{reader_name: ^reader_name}] = Repo.all(Device)
      assert [%Card{uid: ^uid}] = Repo.all(Card)
      assert first_id in Repo.all(from(cr in CardRead, select: cr.id))

      assert {:ok, %CardRead{id: second_id, device_reader_name: ^reader_name, card_uid: ^uid}} =
               execute(%{
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

    test "fails with invalid params" do
      assert {:error, %Ecto.Changeset{valid?: false}} = execute(%{})

      assert {:error, %Ecto.Changeset{valid?: false}} =
               execute(%{uid: "Invalid", reader_name: "valid_name", state: :inserted})

      assert {:error, %Ecto.Changeset{valid?: false}} =
               execute(%{
                 uid: "012356ABCDEF",
                 reader_name: "Invalid reader name",
                 state: :inserted
               })

      assert {:error, %Ecto.Changeset{valid?: false}} =
               execute(%{uid: "012356ABCDEF", reader_name: "valid_name", state: :invalid_state})
    end
  end

  defp execute(params) do
    IvhsBroker.UseCase.execute(IvhsBroker.UseCase.CardReads.HandleCardEvent, params)
  end
end
