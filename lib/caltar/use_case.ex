defmodule Caltar.UseCase do
  alias Caltar.Schema.User
  alias Caltar.Repo

  defmacro __using__(_) do
    quote do
      use Box.UseCase

      import Caltar.UseCase, only: [authorize: 2]
    end
  end

  @type use_case :: module()
  @type params :: any()
  @type options :: Keyword.t()

  @spec execute!(use_case(), params(), options()) :: any()
  def execute!(module, params, options \\ []) do
    Box.UseCase.execute!(module, params, with_default_options(options))
  end

  @spec execute(use_case(), params(), options()) :: any()
  def execute(module, params, options \\ []) do
    Box.UseCase.execute(module, params, with_default_options(options))
  end

  defp with_default_options(options) do
    Keyword.put(options, :run, &Repo.transaction/2)
  end

  def authorize(use_case_options, options \\ []) do
    case {Keyword.get(use_case_options, :user), Keyword.get(options, :required, true)} do
      {nil, true} ->
        {:error, :unauthorized}

      {nil, false} ->
        {:ok, nil}

      {:system, _} ->
        {:ok, :system}

      {%User{} = user, _} ->
        {:ok, user}
    end
  end
end
