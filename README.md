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
# Troubleshooting
- How to prevent vscode automatically add parenthese?
  This is especially annoying for some code, such as Plug related.
  - Solution: seems [no simple solution](https://github.com/elixir-lang/elixir/issues/8165).

