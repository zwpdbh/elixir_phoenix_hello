defmodule HelloWeb.ThermostatLive do
  use Phoenix.LiveView
  alias Hello.Thermostat

  def mount(_params, %{"current_uuid" => user_id}, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    case Thermostat.get_user_reading(user_id) do
      {:ok, temperature} ->
        {:ok, assign(socket, %{temperature: temperature, user_id: user_id})}

      {:error, reason} ->
        reason |> IO.inspect(label: "#{__MODULE__} 13")
        {:ok, redirect(socket, to: "/error")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)

    {:ok, temperature} = Thermostat.get_user_reading(socket.assigns.user_id)
    {:noreply, assign(socket, %{temperature: temperature})}
  end

  def render(assigns) do
    ~H"""
    Current temperature: <%= @temperature %>
    """
  end
end
