# Notes about Phoenix.LiveView

## [Component](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html)

What is a function component ? \
Any function that takes an `assigns` map and returns a rendered struct with the [`~H` sigial](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2).

### Attributes

- How to define expected attributes statically for a function component ? \
  Use [`attr/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#attr/3) before the corresponding function component definition.

  ```elixir
  attr :name, :string, default: "Bob"
  attr :age, :integer, required: true

  def celebrate(assigns) do
    ~H"""
    <p>
      Happy birthday <%= @name %>!
      You are <%= @age %> years old.
    </p>
    """
  end
  ```

  When use the above function component in a heex file

  ```elixir
  <.celebrate name={"Genevieve"} age={34} />
  ```

  Which will be rendered into HTML as

  ```html
  <p>Happy birthday Genevieve! You are 34 years old.</p>
  ```

- How to support dynamic attributes ? \
  We want the pass some common HTML attributes to the function component without hardcode those component in it. \

  1. Use `:global` to declare an attribute. Usually this attribute will be used with some HTML element.

  ```elixir
  attr :message, :string, required: true
  attr :rest, :global

  def notification(assigns) do
    ~H"""
    <span {@rest}><%= @message %></span>
    """
  end
  ```

  2. The caller (in heex file) can pass multiple attributes, such as `phx-*` bindings or standard HTML attributes.

  ```elixir
  <.notification message="You've got mail!" class="bg-green-200" phx-click="close" />
  ```

  Its corresponding HTML result will be

  ```html
  <span class="bg-green-200" phx-click="close">You've got mail!</span>
  ```

### Global attributes

1. We could also provide default global attributes.

```elixir
attr :rest, :global, default: %{class: "bg-blue-200"}
```

2. Include other attributes in addition to extra global attributes

```elixir
# <.button form="my-form"/>
attr :rest, :global, include: ~w(form)
slot :inner_block
def button(assigns) do
  ~H"""
  <button {@rest}><%= render_slot(@inner_block) %></button>
  """
end
```

The `:include` option is useful to apply global additions on a case-by-case basis

3. Custom global attribute prefixes

TODO

### [Slot](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#module-slots)
