defmodule HelloWeb.CartController do
  use HelloWeb, :controller
  alias Hello.ShoppingCart

  def show(conn, _params) do
    render(conn, :show, changeset: ShoppingCart.change_cart(conn.assigns.cart))
  end
end
