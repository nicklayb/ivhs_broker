defmodule Caltar.Accounts do
  alias Caltar.Accounts.UseCase
  alias Caltar.Schema.User
  alias Caltar.Repo

  @doc "Logins a user"
  @spec login(User.email(), User.password()) :: Box.Result.t(User.t(), :not_found)
  def login(email, password) do
    with {:ok, %User{password: password_hash} = user} <- get_user_by_email(email),
         true <- Argon2.verify_pass(password, password_hash) do
      {:ok, user}
    else
      _ ->
        Argon2.no_user_verify()
        {:error, :not_found}
    end
  end

  defp get_user_by_email(email), do: Repo.fetch_by(User, email: String.downcase(email))

  @doc "Gets a user by id"
  @spec get_user_by_id(Repo.record_id()) :: Box.Result.t(User.t(), :not_found)
  def get_user_by_id(id) do
    User
    |> Repo.fetch(id)
    |> Box.Result.map(&Repo.preload(&1, [:folder]))
  end

  @doc "Creates a user"
  @spec create_user(map(), Keyword.t()) :: Box.Result.t(User.t(), any())
  def create_user(params, options \\ []) do
    Caltar.UseCase.execute(UseCase.CreateUser, params, options)
  end
end
