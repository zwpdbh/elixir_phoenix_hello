defmodule HelloWeb.Router do
  use HelloWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {HelloWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    # plug(HelloWeb.Plugs.Locale, "en")

    plug(:fetch_current_user)
    plug(:fetch_current_cart)
  end

  defp fetch_current_user(conn, _opt) do
    if user_uuid = get_session(conn, :current_uuid) do
      assign(conn, :current_uuid, user_uuid)
    else
      new_uuid = Ecto.UUID.generate()

      conn
      |> assign(:current_uuid, new_uuid)
      |> put_session(:current_uuid, new_uuid)
    end
  end

  alias Hello.ShoppingCart

  defp fetch_current_cart(conn, _opt) do
    if cart = ShoppingCart.get_cart_by_user_uuid(conn.assigns.current_uuid) do
      assign(conn, :cart, cart)
    else
      {:ok, new_cart} = ShoppingCart.create_cart(conn.assigns.current_uuid)
      assign(conn, :cart, new_cart)
    end
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", HelloWeb do
    pipe_through :api
    resources "/urls", UrlController, except: [:new, :edit]
  end

  scope "/", HelloWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/redirect_test", PageController, :redirect_test)

    get("/hello", HelloController, :index)
    get("/hello/:messenger", HelloController, :show)

    resources("/products", ProductController)

    # For shopping cart features
    resources("/cart_items", CartItemController, only: [:create, :delete])
    get("/cart", CartController, :show)
    put("/cart", CartController, :update)

    resources "/orders", OrderController, only: [:create, :show]

    # For liveview
    live "/thermostat", ThermostatLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hello, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: HelloWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
