# Beware, this module's name is controller name + HTML (not Html)
defmodule HelloWeb.HelloHTML do
  use HelloWeb, :html

  # There are two ways to define a certain template in view module
  # 1) functional component
  # def index(assigns) do
  #   ~H"""
  #   Hello!
  #   """
  # end

  # 2) template file
  # Here, we are including all ".heex" file into this view module for rendering
  # For a specific template, such as "index":
  # We will create file "hello_html/index.html.heex".
  embed_templates("hello_html/*")

  # Here, we use functional component
  def show(assigns) do
    ~H"""
      <h2>Hello World, from <%= assigns.messenger %>!</h2>
    """
  end
end
