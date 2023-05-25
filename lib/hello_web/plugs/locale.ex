defmodule HelloWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "fr", "de"]

  def init(default) do
    default
  end

  # Now visit any address with query parameter: locale=fr
  # For example: http://localhost:4000/hello?locale=fr
  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    assign(conn, :locale, loc)
  end
end
