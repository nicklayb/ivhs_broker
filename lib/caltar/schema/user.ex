defmodule Caltar.Schema.User do
  use Caltar, :schema

  alias Caltar.Schema.User

  @type email :: String.t()
  @type password :: String.t()

  schema("users") do
    field(:name, :string)
    field(:email, :string)

    field(:password, :string)
    field(:password_confirmation, :string, virtual: true)

    timestamps()
  end

  @required ~w(name email password password_confirmation)a

  def create_changeset(%User{} = user \\ %User{}, params) do
    user
    |> Ecto.Changeset.cast(params, @required)
    |> Ecto.Changeset.validate_required(@required)
    |> Ecto.Changeset.validate_confirmation(:password)
    |> Box.Ecto.Changeset.hash(:password, hash_function: &Argon2.hash_pwd_salt/1)
    |> Ecto.Changeset.validate_format(:email, ~r/@/)
    |> Ecto.Changeset.update_change(:email, &String.downcase/1)
  end
end
