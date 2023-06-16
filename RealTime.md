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

## Example

A simple chat application

1. Generating a socket
