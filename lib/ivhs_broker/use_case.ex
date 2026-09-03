defmodule IvhsBroker.UseCase do
  alias IvhsBroker.Repo

  defmacro __using__(_) do
    quote do
      use Box.UseCase
      import IvhsBroker.UseCase, only: [notify: 2]
      use Gettext, backend: IvhsBrokerWeb.Gettext
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

  def notify(options, notify_params) do
    with {:ok, session_id} <- Keyword.fetch(options, :session_id) do
      IvhsBroker.PubSub.broadcast("notifications:#{session_id}", {:notify, notify_params})
    end

    :ok
  end
end
