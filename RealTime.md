# Real Time

This document records my learning note from [Real Time -- channels](https://hexdocs.pm/phoenix/channels.html)

## Channels

- First, Client connect to server using some transport (ie, WebSocket).
- After that, client need to join one or more topic to push or receive messages from channel server.
  - Channel server can also receives messages from their connected clients and can push messages to them.
  - Message is send and receive in channel (topic) even across different nodes.
  - So in other words, only topic matters.
- Channels are the highest level abstraction for real-time communication components in Phoenix.

### The Moving Parts

- One channel server process < -- > {per client, per topic}.
- Each channel < -- > `%Phoenix.Socket{}` and its state is in `socket.assigns`.
- Local PubSub and Remote PubSub.

### Server Endpoint

On server, config how transport is supported. Such as

```elixir
socket "/socket", HelloWeb.UserSocket,
  websocket: true,
  longpoll: false
```

### Client Handlers

On client, we could connect the above endpoint using javascript as

```javascript
let socket = new Socket("/socket", { params: { token: window.userToken } });
```

On the server, Phoenix will invoke `HelloWeb.UserSocket.connect/2`, passing your parameters and the initial socket state.

### Channel Routes and topics

- Channels handle events similar to Controllers.
- Each channel will implement one or more clauses:

  - `join/3`
  - `terminate/2`
  - `handle_in/3`
  - `handle_out/3`

- Topics
  - Convention: "topic:subtopic"

### [Message](https://hexdocs.pm/phoenix/Phoenix.Socket.Message.html)

- A struct with the following keys
  - topic
  - event
  - payload
  - ref

### [PubSub](https://hexdocs.pm/phoenix_pubsub/2.1.3/Phoenix.PubSub.html)

- Subscribe topic
- Broadcast to topic
- If your deployment environment does not support distributed Elixir or direct communication between servers, Phoenix also ships with a [Redis Adapter](https://hexdocs.pm/phoenix_pubsub_redis/Phoenix.PubSub.Redis.html) that uses Redis to exchange PubSub data.

## A simple chat application

1. Generating a socket

```sh
mix phx.gen.socket User
* creating lib/hello_web/channels/user_socket.ex
* creating assets/js/user_socket.js

Add the socket handler to your `lib/hello_web/endpoint.ex`, for example:

    socket "/socket", HelloWeb.UserSocket,
      websocket: true,
      longpoll: false

For the front-end integration, you need to import the `user_socket.js`
in your `assets/js/app.js` file:

    import "./user_socket.js"
```

- We generate two files which establish a websocket connection between client and server.
- On client, we use JavaScript to connect to our server (assets/js/app.js).
- On server

  - We enable the transport which uses websocket (lib/hello_web/endpoint.ex).
  - Define how a message get routed to a channel (lib/hello_web/channels/user_socket.ex).

    ```elixir
    defmodule HelloWeb.UserSocket do
    use Phoenix.Socket

    ## Channels
    channel "room:*", HelloWeb.RoomChannel
    ...
    ```

    - Now, whenever a client sends a message whose topic starts with "room:", it will be routed to our `RoomChannel`.
    - It is very similar with how Http request is routed to a controller.

2. Create Channel Module to handle message

- Create `lib/hello_web/channels/room_channel.ex` to define `RoomChannel` module.
- In `Channel`, we define how client join a given topic.

### Summary of Establishing Connection.

`mix phx.gen.socket User` generates two coordiate files to set up a connection between client and server.

On client side:

- Create a socket connection to server.
- With socket is connected: join different channels with topic.
- Notice: When join a channel, client must specify a topic. Make sure it match the topics defined in the channel module from server (see below).

On server side:

- Define use websocket for connection.
- Define a channel and create its corresponding channel module.
- Define how client join a topic in the channel module.

So far, we should see "Joined successfully" in the browser's JavaScript console. Our client and server are now talking over a persistent connection.

### Enabling Chat
