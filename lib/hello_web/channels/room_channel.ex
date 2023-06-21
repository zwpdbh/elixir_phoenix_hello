defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel

  # Each channel subscriber can choose to intercept the event and have their handle_out/3 callback triggered
  intercept ["new_msg"]

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  def handle_out("new_msg", msg, socket) do
    push(
      socket,
      "new_msg",
      Map.merge(
        msg,
        %{is_editable: false}
      )
    )

    {:noreply, socket}
  end
end
