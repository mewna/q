defmodule Q do
  @moduledoc """
  Q is a simple, JSON-based, Redis-backed message queue system, for when ex. it
  doesn't make sense to have your nodes join a cluster together.

  Queued elements are *automatically* encoded into JSON; if you pass a binary,
  Q assumes that it's already valid JSON and **will not attempt to validate it
  for you**.

  ## Configuration

      %{
        queue: "redis queue name",
        host: "localhost",
        port: 6379,
        pass: "a",
        event_handler: &MyModule.handle/1,
      }

  The function passed as the `event_handler` is expected to take a single
  argument, which will be the decoded JSON data popped from the queue.

  ## Usage

  Start it supervised however idk. Pass the stuff in the configuration section above

      GenServer.cast :your_queue, {:queue, "memes"}
  """

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link __MODULE__, opts
  end

  def init(opts) do
    state = %{
      queue: opts[:queue],
      redix: Redix.start_link([
        host: opts[:host],
        port: opts[:port],
        password: opts[:pass],
      ]),
      event_handler: opts[:event_handler]
    }
    if opts[:poll] do
      Process.send_after self(), :poll, 250
    end
    {:ok, state}
  end

  def handle_info(:poll, state) do
    {:ok, data} = Redix.command state[:redix], ["BLPOP", state[:queue], "0"]

    # Pass data off to handler
    state[:event_handler].(data)

    send self(), :poll
    {:noreply, state}
  end

  def handle_cast({:queue, data}, state) when is_binary(data) do
    Redix.command state[:redix], ["RPUSH", state[:queue], data]
    {:noreply, state}
  end
  def handle_cast({:queue, data}, state) do
    Redix.command state[:redix], ["RPUSH", state[:queue], Jason.encode!(data)]
    {:noreply, state}
  end

  @doc """
  Hello world.

  ## Examples

      iex> Q.hello
      :world

  """
  def hello do
    :world
  end
end
