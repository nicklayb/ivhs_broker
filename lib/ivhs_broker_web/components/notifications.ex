defmodule IvhsBrokerWeb.Components.Notifications do
  use IvhsBrokerWeb, :live_view
  alias IvhsBrokerWeb.Components.Notifications.Message

  def mount(_, session, socket) do
    socket =
      socket
      |> assign(:session_id, session["session_id"])
      |> assign(:__topics__, [])
      |> assign(:notifications, [])
      |> subscribe()

    {:ok, socket}
  end

  def handle_info({:notification, :dismiss, id}, socket) do
    socket = delete_notification(socket, id)

    {:noreply, socket}
  end

  def handle_info(
        %Box.PubSub.Message{
          topic: "notifications:" <> _session_id,
          message: :notify,
          params: params
        },
        socket
      ) do
    socket = push_notification(socket, params)
    {:noreply, socket}
  end

  def handle_event("dismiss", %{"notification_id" => notification_id}, socket) do
    socket = delete_notification(socket, notification_id)
    {:noreply, socket}
  end

  defp subscribe(socket) do
    map_connected(socket, fn socket ->
      session_id = socket.assigns.session_id
      subscribe(socket, "notifications:#{session_id}")
    end)
  end

  defp push_notification(socket, params) do
    update(socket, :notifications, &[Message.new(params) | &1])
  end

  defp delete_notification(socket, id) do
    map_notification(socket, id, fn notification ->
      {:delete, Message.delete(notification)}
    end)
  end

  defp map_notification(socket, notification_id, function) do
    update(socket, :notifications, fn notifications ->
      notifications
      |> Enum.reduce([], fn
        %Message{id: ^notification_id} = message, acc ->
          case function.(message) do
            {:delete, _} ->
              acc
          end

        %Message{} = message, acc ->
          [message | acc]
      end)
      |> Enum.reverse()
    end)
  end

  def render(assigns) do
    ~H"""
    <%= if Enum.any?(@notifications) do %>
      <aside
        class="fixed bottom-4 right-4 z-50 flex w-[calc(100%-2rem)] max-w-sm flex-col gap-3 sm:bottom-6 sm:right-6"
        aria-label="Notifications"
      >
        <%= for notification <- Enum.reverse(@notifications) do %>
          <.render_message message={notification} />
        <% end %>
      </aside>
    <% end %>
    """
  end

  @classes %{
    info: "bg-info",
    success: "bg-success",
    error: "bg-warning"
  }

  def render_message(assigns) do
    {title, icon} =
      case assigns.message.type do
        :info -> {gettext("Info"), "i"}
        :error -> {gettext("Error"), "!"}
        :success -> {gettext("Success"), "✓"}
      end

    assigns =
      assigns
      |> assign(:class, Map.fetch!(@classes, assigns.message.type))
      |> assign(:title, title)
      |> assign(:icon, icon)

    ~H"""
    <div
      role="alert"
      class={Box.Html.class(["border-2 border-ink shadow-[4px_4px_0_#25251f]", @class])}
    >
      <div class="flex items-start gap-3 p-4">
        <div class="flex h-8 w-8 shrink-0 items-center justify-center border-2 border-ink bg-paper font-mono text-sm font-black">
          {@icon}
        </div>

        <div class="min-w-0 flex-1">
          <div class="text-xs font-black uppercase tracking-wider">{@title}</div>

          <p class="mt-1 text-sm font-medium leading-relaxed">
            {@message.message}
          </p>
        </div>

        <button
          type="button"
          aria-label="Close notification"
          phx-click="dismiss"
          phx-value-notification_id={@message.id}
          class="flex h-7 w-7 shrink-0 items-center justify-center border-2 border-ink bg-paper font-mono text-sm font-black hover:bg-ink hover:text-paper"
        >
          ×
        </button>
      </div>

      <div class="h-1 bg-ink/20">
        <div class="h-full w-full bg-ink"></div>
      </div>
    </div>
    """
  end
end
