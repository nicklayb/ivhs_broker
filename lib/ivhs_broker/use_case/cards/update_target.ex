defmodule IvhsBroker.UseCase.Cards.UpdateTarget do
  use IvhsBroker, :use_case
  alias IvhsBroker.Cards
  alias IvhsBroker.Schema.Card

  @impl Box.UseCase
  def validate({card_uid, params}, _options) do
    with {:ok, %Card{} = card} <- Cards.get_card(card_uid),
         %Ecto.Changeset{valid?: true} = changeset <- Card.target_changeset(card, params) do
      {:ok, {card, changeset}}
    else
      {:error, _} = error ->
        error

      %Ecto.Changeset{} = changeset ->
        {:error, {:validation_error, changeset}}
    end
  end

  @impl Box.UseCase
  def run(multi, {_card, changeset}, _options) do
    Ecto.Multi.update(multi, :card, changeset)
  end

  @impl Box.UseCase
  def return(%{card: card}, _options) do
    card
  end

  @impl Box.UseCase
  def after_run(%{card: card}, _) do
    IvhsBroker.PubSub.broadcast(["cards:#{card.uid}"], {:updated, card})
  end
end
