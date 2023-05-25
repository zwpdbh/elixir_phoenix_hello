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