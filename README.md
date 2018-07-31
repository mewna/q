# Q

Q is a simple, JSON-based, Redis-backed message queue system, for when ex. it
doesn't make sense to have your nodes join a cluster together.

Queued elements are *automatically* encoded into JSON; if you pass a binary,
Q assumes that it's already valid JSON and **will not attempt to validate it
for you**.

## Configuration

```Elixir
%{
  queue: "redis queue name",
  host: "localhost",
  port: 6379,
  pass: "a",
  event_handler: &MyModule.handle/1,
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
