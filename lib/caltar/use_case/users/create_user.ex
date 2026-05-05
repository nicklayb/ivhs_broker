defmodule Caltar.UseCase.Users.CreateUser do
  use Caltar.UseCase

  @impl Box.UseCase
  def validate(params, _options) do
    changeset = Caltar.Schema.User.create_changeset(params)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  @impl Box.UseCase
  def run(multi, changeset, _options) do
    Ecto.Multi.insert(multi, :user, changeset)
  end

  @impl Box.UseCase
  def return(%{user: user}, _options) do
    user
  end
end
