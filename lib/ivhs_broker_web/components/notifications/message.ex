defmodule IvhsBrokerWeb.Components.Notifications.Message do
  alias IvhsBrokerWeb.Components.Notifications.Message
  @default_timeout :timer.seconds(5)

  defstruct [:id, :message, :timer_ref, type: :info, timeout: @default_timeout]

  def new(params) do
    {schedule_timer?, params} = Keyword.pop(params, :schedule_timer?, true)

    Message
    |> struct(params)
    |> put_id()
    |> then(fn message ->
      if schedule_timer? do
        schedule_timer(message)
      else
        message
      end
    end)
  end

  defp put_id(%Message{} = message), do: %Message{message | id: Ecto.UUID.generate()}

  defp schedule_timer(%Message{timeout: nil} = message), do: message

  defp schedule_timer(%Message{timeout: timeout} = message) do
    timer = Process.send_after(self(), {:notification, :dismiss, message.id}, timeout)
    %Message{message | timer_ref: timer}
  end

  def delete(%Message{timer_ref: timer_ref} = message) do
    if is_reference(timer_ref), do: Process.cancel_timer(timer_ref)
    %Message{message | timer_ref: nil}
  end
end
