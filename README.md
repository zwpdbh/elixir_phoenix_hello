# Hello

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix



# My Notes 
Records the learning points by following the Phoenix offical documents

## Components
- Endpoint, the entry point for all http request. 
- Router, defines the rules to dispatch request to controllers.
- Controller, defines the view module to render HTML to client.
- Telemetry, collect metrics and send monitoring events of our application.

## From endpoint to views 
Use elixir dummy sudo code to represent
```elixir 
request 
|> endpoint 
|> router # It maps http request to one action of a controller 
|> controller  # Inside the controller action, we define which template from view to render.
|> template # Either functional component or embed_templates to render the template.
```

## Where to use Plug 
- [Endpoint plugs](https://hexdocs.pm/phoenix/plug.html#endpoint-plugs)
  - We could add plugs in endpoint to make it available to all requests. 
- [Router plugs](https://hexdocs.pm/phoenix/plug.html#router-plugs)
  - Routes are defined inside scopes.
    - Inside a scope, we could pipe_through multiple pipeline.
  - We add plugs inside the pipeline. 
    - Inside a pipeline, there could be multiple plugs.
- [Controller plugs](https://hexdocs.pm/phoenix/plug.html#controller-plugs)
  - Allow us to execute plugs only within certain actions. 
  - A good example for showing [how to compose plugs and used in controller](https://hexdocs.pm/phoenix/plug.html#plugs-as-composition).

## Routing 
- Use [resources](https://hexdocs.pm/phoenix/routing.html#resources) to define REST for a resource 
  - For example, `resources "/users", UserController` will automatically add the following routes for us, a standard matrix of HTTP verbs, paths, and controller actions:
    ```text
    ...
    GET     /users           HelloWeb.UserController :index
    GET     /users/:id/edit  HelloWeb.UserController :edit
    GET     /users/new       HelloWeb.UserController :new
    GET     /users/:id       HelloWeb.UserController :show
    POST    /users           HelloWeb.UserController :create
    PATCH   /users/:id       HelloWeb.UserController :update
    PUT     /users/:id       HelloWeb.UserController :update
    DELETE  /users/:id       HelloWeb.UserController :delete
    ...
    ```
  - We could define [Nested resources](https://hexdocs.pm/phoenix/routing.html#nested-resources)!
- [Verify routes](https://hexdocs.pm/phoenix/routing.html#verified-routes) throughout web layer by using `~p`.
  - It verify the route exists at compile time.

- The purpose of scope is to group similar routes with common path prefix together.
  - For example, we want to group admin related route into a different group, seperate from other actions 
    ```elixir 
    scope "/", HelloWeb do
      pipe_through :browser

      ...
      resources "/reviews", ReviewController
    end

    scope "/admin", HelloWeb.Admin do
      pipe_through :browser

      resources "/reviews", ReviewController
    end
    ```
  - The above example will create multiple actions for different scope for different prefix route: `/` vs `/admin`.
  - We could define [two scope with the same prefix path](https://hexdocs.pm/phoenix/routing.html#how-to-organize-my-routes). 

- [Pipelines](https://hexdocs.pm/phoenix/routing.html#pipelines) are a series of plugs that can be attached to a certain scope.
  - We could create custom pipeline anywhere in the router.
  - For example, [define a new pipeline](https://hexdocs.pm/phoenix/routing.html#creating-new-pipelines) for authentication and add series of plugs to it.
  - Don't remember to attache the pipeline to a scope.

- Use `forward` to [forward]https://hexdocs.pm/phoenix/routing.html#forward() all request with a prefix path to a plug.

## Controllers 
- A intermediary modules act between route and view. It is also a plug by itself.
- Controller functions (actions) [naming convension](https://hexdocs.pm/phoenix/controllers.html#actions).
  - Each function always has signature: `(conn, params)`

- There are several ways for controller to render content 
  - `text/2` 
  - `json/2`, useful for writing APIs.
  - `html/2`
  - `render/3`
    - Controller and view must share the same root name (in our case, it is `Hello`).
    - Use functional component or embed_templates. 
    - By default the controller, view module, and templates are collocated together in the same controller directory.
- We could make a controller to support render both html and json by specifying which views to use for each format.
  - In controller, explicitly set the following:
    ```elixir 
    plug :put_view, html: HelloWeb.PageHTML, json: HelloWeb.PageJSON
    ```
  - Create view module `HelloWeb.PageJSON` and return json object from template.
  - Edit router to be: `plug :accepts, ["html", "json"]`.

- Setting the content type
  ```elixir 
  conn
  |> put_resp_content_type("text/xml")
  |> render(:home, content: some_xml_content)
  ```
  
- Setting the HTTP Status
  ```elixir 
  conn
  |> put_status(202)
  |> render(:home, layout: false)
  ```

### Redirection
- Redirect within application using `~p` sigil.
- Redirect outside URL with full-quanlified path.

## Components and HEEX
- What is function component ?
  Any function that accepts an assigns parameter and returns a HEEx template to be a function component.

## Ecto 
- Create schema by using `mix ecto.gen.migration <migration_name>`.
  - This will create a migration file and let us to edit it to fill it with any schema definition.
  - We could also [define schema](https://hexdocs.pm/phoenix/ecto.html#using-the-schema-and-migration-generator) directly by using `mix phx.gen.schema`
- `Changeset` define a pipeline of transformations our data needs to undergo before it will be ready for our application to use.
- `Repo` take care of the finer details of persistence and data querying for us.
  - We pass a changeset to `Repo.insert/2` to insert.
  - We cound also  insert data model directly.

## Contexts 
- What are contexts ? [Thinking about design](https://hexdocs.pm/phoenix/contexts.html#thinking-about-design)
  - Contexts are dedicated modules that expose and group related functionality.
  - In Phoenix, contexts often encapsulate data access and data validation.
- How to come up a name for context? 
  - If you're stuck when trying to come up with a context name when the grouped functionality in your system isn't yet clear, you can simply use the plural form of the resource you're creating.
  - For example, a Products context for managing products. As you grow your application and the parts of your system become clear, you can simply rename the context to a more refined one.

- Helper functions 
  - `mix phx.gen.html`
  - `mix phx.gen.json`
  - `mix phx.gen.live`
  - `mix phx.gen.context`

  The differences between `mix phx.gen.context` vs `mix phx.gen.html` is that: `mix phx.gen.context` won't generate web related files for us. 

- Example: Create A context for showcasing a product and managing the exhibition of products.
  - Generate context `Catalog`
    ```elixir 
    mix phx.gen.html Catalog Product products title:string description:string price:decimal views:integer
    ```
    It generates 4 parts
    - Context module `Hello.Catalog` in `lib/hello/catalog.ex`.
    - Schema module `Hello.Catalog.Product` in `lib/hello/catalog/product.ex`.
    - Web controller and views for `product`: 
      - `HelloWeb.ProductController`, controller module in `lib/hello_web/controllers/product_controller.ex`.
      - `HelloWeb.ProductHTML`, view module in `lib/hello_web/controllers/product_html.ex`.
      - Several template files such as`xxx.heex.html` in folder `lib/hello_web/controllers/product_html`.
    - Test related files. 
  - Run `mix ecto.migrate`.
  - Edit `lib/hello_web/router.ex to` to include `resources "/products", ProductController`.

- What have learned from above example: 
  - Our Phoenix controller is the web interface into our greater application. Our business logic and storage details are decoupled by context.
    - Therefore, the controller talks to`Catelog` context module instead of `Product` schema module. 
      - Visit to product in Router <> actions in controller. 
      - Do business stuff: controller <> context. 
      - Do schema stuff: context <> schema.
    - In other words, from controller's point of view, how product fetching and creation is happening under the hood. 

- Example: Add new functions into context.
  - Suppose we want to [tracking product page view count](https://hexdocs.pm/phoenix/contexts.html#adding-catalog-functions). 
  - Think of a function that describes what we want to accomplish and be careful the race condition. 



### [In-context Relationships](https://hexdocs.pm/phoenix/contexts.html#in-context-relationships) 
- How to determine if two resources belong to the same context or not?  
  In general, if you are unsure, you should prefer separate modules (contexts).
- How to add a many to many relationship to an existing resource ? 
  For example, a product can have multiple categories, and a category can contain multiple products. 
  - Create `Category` by: `mix phx.gen.context Catalog Category categories`.
  - Create relationship table by: `mix ecto.gen.migration create_product_categories`.
    - Define table with foreign_key, index and unique_index.
  - Fill sample data using `priv/repo/seeds.exs`.
  - Modify existing `lib/hello/catalog/product.ex` schema to add many_to_many relationship to categories.
  - Modify existing `lib/hello/catalog.ex` context. 
    - Modify product to repload categories.
    - When change product
      - When fetch product, also load categories from category_ids.
      - For change a product: Preload categories and do changeset, then put_assoc
        ```elixir 
        def change_product(%Product{} = product, attrs \\ %{}) do
          # Product.changeset(product, attrs)
          categories = list_categories_by_id(attrs["category_ids"])

          product
          |> Repo.preload(:categories)
          |> Product.changeset(attrs)
          |> Ecto.Changeset.put_assoc(:categories, categories)
        end
        ```
  - Adding the category input to the product form.
    - Create new function component `lib/hello_web/controllers/product_html.ex`.
    - Use function component in `lib/hello_web/controllers/product_html/product_form.html.heex` for selecting categories in product form.
    - Modify `lib/hello_web/controllers/product_html/show.html.heex` to show categories for a product.

### [Cross-context dependencies](https://hexdocs.pm/phoenix/contexts.html#cross-context-dependencies) 
In order to properly track products that have been added to a user's cart, we build the "carting products from the catalog" feature.

- Generate `Cart` in  `ShoppingCart` context 
  ```sh 
  mix phx.gen.context ShoppingCart Cart carts user_uuid:uuid:unique
  ```

- Generate `CartItem` in `ShoppingCart` context. 
  ```sh 
  mix phx.gen.context ShoppingCart CartItem cart_items \
  cart_id:references:carts product_id:references:products \
  price_when_carted:decimal quantity:integer
  ```
- Do further modification to the generated migration file `create_cart_items.exs` to enhance:
  - price precision and scale
  - foreign_key's on_delete operation 
  - create unique index from two index's combination

- Run `mix ecto.migrate`.

- Do cross-context data 
  - Setup association for schemas which has dependencies for each other. In our case, `ShoppingCart` context have a data dependency on the `Catalog` context. 
    - One solution is to use database joins to fetch the dependent data. (Our choice).
    - Another one is to expose APIs on the `Catalog` context to allow us to fetch product data for use in the `ShoppingCart` system.
  - Notice `has_many` vs `belong_to`
    - `Cart` has many `CartItem`.
    - `CartItem` belong to `Cart`, 
    - `CartItem` belong to `Product`

- Adding Shopping Cart functions
  See: https://hexdocs.pm/phoenix/contexts.html#adding-shopping-cart-functions


# Other references
## About Ecto
- [Understanding Associations in Elixir's Ecto](https://blog.appsignal.com/2020/11/10/understanding-associations-in-elixir-ecto.html)

# Troubleshooting
- How to prevent vscode automatically add parenthese?
  This is especially annoying for some code, such as Plug related.
  - Solution: seems [no simple solution](https://github.com/elixir-lang/elixir/issues/8165).

