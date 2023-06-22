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

  In other words, function component's attribute is like parameters to a function.

### Global attributes

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



- How to provide global attributes with default value 

  ```elixir
  attr :rest, :global, default: %{class: "bg-blue-200"}
  ```

  Now we could call the function component without a class attribute: 

  ```heex
  <.notification message="You've got mail!" phx-click="close" />
  ```

  It results html as 
  ```
  <span class="bg-blue-200" phx-click="close">You've got mail!</span>
  ```

- Include other attributes in addition to extra global attributes

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

  The `:include` option is useful to apply global additions on a case-by-case basis. This means when there are a lot of attributes in global, we could just select a specific one to apply.

- Custom global attribute prefixes
  - This is used to include extra global attributes in addition to phoenix framework.
  - For example, we want to use some global attributes from [Alpine.js](https://alpinejs.dev/)
    
    ```elixir 
    def html do
      quote do
        use Phoenix.Component, global_prefixes: ~w(x-)
        # ...
      end
    end
    ```
    - This is typically defined in `lib/my_app_web.ex`.
    - Now all function components invoked by this module will accept any number of attributes prefixed with `x-` which is used by `Alpine.js`, in addition to the default global prefixes. 


### [Slot](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#module-slots)
- Slot is like anothe kind of parameter to a function component. You can pass block of HEEx content to a function component.
- Similar how `attr` is used to define parameter to a function component, here it is `slot`: 
  
  ```elixir 
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
  ```

  Now, pass the button function component with HEEx content
  ```html 
  <.button>
    This renders <strong>inside</strong> the button!
  </.button>
  ```

  The rendered HTML will be 
  ```
  <button>
    This renders <strong>inside</strong> the button!
  </button>
  ```

- How to render a dynamic slot? -- using default slot 
  - For example, the content or values rendered in the slot need to be dynamic. In other words, we want to make the slot accept parameter.
  - We could use `render_slot/2` with parameter. See [default slot](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#module-the-default-slot) for details.
  - Default slot is accessible as an assign named `@inner_block`

- Named slot is a good option when we need to pass multiple slot to a function component. 
  - Like named parameter, we first define them with name, and when used we annotate the slot we passed with name. 
  
    ```elixir 
    slot :header
    slot :inner_block, required: true
    slot :footer, required: true

    def modal(assigns) do
      ~H"""
      <div class="modal">
        <div class="modal-header">
          <%= render_slot(@header) || "Modal" %>
        </div>
        <div class="modal-body">
          <%= render_slot(@inner_block) %>
        </div>
        <div class="modal-footer">
          <%= render_slot(@footer) %>
        </div>
      </div>
      """
    end
    ```

    Invoke the function component and passing named slot:
    ```heex
    <.modal>
      This is the body, everything not in a named slot is rendered in the default slot.
      <:footer>
        This is the bottom of the modal.
      </:footer>
    </.modal>
    ```

  - See [Named slot](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#module-named-slots) for complete example.

- Use slot with attribute 
  - In the example, we use slot to build a table dynamically: The named slot is column. 
  - See [Slot attributes](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#module-slot-attributes) example. 

- [Embedding external template files](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#module-embedding-external-template-files)
  - We invoke function component in heex file in most of time.  But we could also use heex file as slot in function component.
  - This is done by [embed_templates/1](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#embed_templates/1) which embed `.html.heex` files as function components.


## [LiveComponent](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html) 

- What is the differences between LiveComponent and Component?
  - LiveComponent is a stateful component while Component is stateless (that is why component is called function component).
  - Notice: 
    - Must always pass the `module` and `id` attributes when used in `.html.heex` file.
    - All other attributes will be available as assigns inside the LiveComponent.

### [Life-cyle](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-life-cycle)
- Mount and update 
- Events 
  - A LiveComponent can send event to a target which is another LiveComponent using its id. 
- [Preloading and update](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-preloading-and-update)
  - Why it is needed? 
    - Suppose we have a user component and it need to load some state from database.
    - If we fetch data in the `update/2` callback, it sends n + 1 query when rending multiple user components in the same page. 
    - It is useful because it is invoked with a list of assigns for all components of the same type.
  
      ```elixir 
      def preload(list_of_assigns) do
        list_of_ids = Enum.map(list_of_assigns, & &1.id)

        users =
          from(u in User, where: u.id in ^list_of_ids, select: {u.id, u})
          |> Repo.all()
          |> Map.new()

        Enum.map(list_of_assigns, fn assigns ->
          Map.put(assigns, :user, users[assigns.id])
        end)
      end
      ```

      Now only a single query to database will be made. 

- See the [life-cycle diagram](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-summary). 

### [Slots](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-slots)

- Same as function component's slot.
- If the LiveComponent defines an `update/2`, be sure that the socket it returns includes the `:inner_block` assign it received.

### [Managing state](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-managing-state)

- Make sure the single source of event. The parent LiveView and the LiveComponent working on should have one state.
- For example, a LiveView represents a board with each card in it as a separate stateful LiveComponent. Each card has a form to allow update of the card title directly in the component.