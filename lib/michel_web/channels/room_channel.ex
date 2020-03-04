defmodule MichelWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("coucou", %{"message" => message}, socket) do
    IO.inspect(message)
    push(socket, "coucou", %{message: "Yo!"})
    {:noreply, socket}
  end
end
