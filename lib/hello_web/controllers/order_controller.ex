defmodule HelloWeb.OrderController do
  use HelloWeb, :controller
  alias Hello.Orders

  @doc """
  Create an Order from a Cart
  """
  def create(conn, _) do
    case Orders.complete_order(conn.assigns.cart) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: ~p"/orders/#{order}")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was an error processing your code")
        |> redirect(to: ~p"/cart")
    end
  end

  @doc """
  Show user the completed order.
  """
  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(conn.assigns.current_uuid, id)
    render(conn, :show, order: order)
  end
end
