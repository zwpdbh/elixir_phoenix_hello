defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  plug(HelloWeb.Plugs.Locale, "en" when action in [:index])

  # The purpose of action is to gather data and perform the rendering.
  def index(conn, _params) do
    # It tells Phoenix to render the "index" template.
    # The corresponding view module match this controller is hello_web.ex and it needs to define a "index" template in the view module.
    render(conn, :index)
  end

  def show(conn, %{"messenger" => messenger} = _params) do
    conn
    |> assign(:messenger, messenger)
    |> render(:show)

    # render(conn, :show, messenger: messenger)
  end
end
