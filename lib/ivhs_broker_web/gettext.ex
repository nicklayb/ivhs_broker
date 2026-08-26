defmodule IvhsBrokerWeb.Gettext do
  use Gettext.Backend, otp_app: :ivhs_broker

  defmacro __using__(_) do
    quote do
      use Gettext, backend: IvhsBrokerWeb.Gettext
    end
  end
end
