defmodule IvhsBroker.Schema.Card.Target.YoutubeTest do
  use IvhsBroker.DataCase

  alias IvhsBroker.Schema.Card.Target.Youtube

  describe "changeset/2" do
    test "casts a video code" do
      code = "dQw4w9WgXcQ"

      assert %Ecto.Changeset{valid?: true, changes: %{code: ^code}} =
               Youtube.changeset(%Youtube{}, %{code: code})
    end

    test "casts a video uri" do
      code = "dQw4w9WgXcQ"
      uri = "https://www.youtube.com/watch?v=#{code}"

      assert %Ecto.Changeset{valid?: true, changes: %{code: ^code}} =
               Youtube.changeset(%Youtube{}, %{code: uri})
    end
  end
end
