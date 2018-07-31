# Q

Q is a simple, JSON-based, Redis-backed message queue system, for when ex. it
doesn't make sense to have your nodes join a cluster together.

Queued elements are *automatically* encoded into JSON; if you pass a binary,
Q assumes that it's already valid JSON and **will not attempt to validate it
for you**.

## Configuration

```Elixir
%{
  # Must be passed. Used for naming the process
  name: :"queue-name",
  # Should be the same between all workers
  queue: "redis queue name",
  # Connecting to redis
  host: "localhost",
  port: 6379,
  pass: "a",
  # Used for handling events pulled from the queue
  event_handler: &MyModule.handle/1,
  # Set this to false to prevent queue polling
  poll: true,
}
```

The function passed as the `event_handler` is expected to take a single
argument, which will be the decoded JSON data popped from the queue.

## Usage

Start it supervised however idk. Pass the stuff in the `configuration` section
above. 

```Elixir
GenServer.cast :your_queue, {:queue, "memes"}
```

Q wil automatically call the function passed as `event_handler` when there is a
new queue item available.

## Installation

Add this to your `mix.exs`:

```elixir
def deps do
  [
    {:q, github: "mewna/q}
  ]
end
```
