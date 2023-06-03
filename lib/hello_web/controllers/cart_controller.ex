defmodule HelloWeb.CartController do
  use HelloWeb, :controller
  alias Hello.ShoppingCart

  def show(conn, _params) do
    render(conn, :show, changeset: ShoppingCart(conn.assigns.cart))
  end
end
