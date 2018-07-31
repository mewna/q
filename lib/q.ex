defmodule Q do
  @moduledoc """
  Q is a simple, JSON-based, Redis-backed message queue system, for when ex. it
  doesn't make sense to have your nodes join a cluster together.

  Queued elements are *automatically* encoded into JSON; if you pass a binary,
  Q assumes that it's already valid JSON and **will not attempt to validate it
  for you**.

  ## Configuration

      %{
        name: :"queue-name",
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
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(opts) do
    {:ok, redix} =
      Redix.start_link(
        host: opts[:host],
        port: opts[:port],
        password: opts[:pass]
      )

    state = %{
      queue: opts[:queue],
      redix: redix,
      event_handler: opts[:event_handler]
    }

    Logger.info("[Q] Ready on queue #{state[:queue]}!")

    if opts[:poll] do
      Process.send_after self(), :poll, 250
      Process.send_after self(), :poll_started, 250
      Logger.info("[Q] Polling will start in 250ms.")
    end

    {:ok, state}
  end

  def handle_info(:poll_started, state) do
    Logger.info "[Q] Polling started."
    {:noreply, state}
  end

  def handle_info(:poll, state) do
    # This can potentially block forever, so it has to have :infinity timeout
    {:ok, data} = Redix.command state[:redix], ["BLPOP", state[:queue], "0"], timeout: :infinity

    # Pass data off to handler
    state[:event_handler].(data)

    send(self(), :poll)
    {:noreply, state}
  end

  def handle_cast({:queue, data}, state) when is_binary(data) do
    Redix.command(state[:redix], ["RPUSH", state[:queue], data])
    {:noreply, state}
  end

  def handle_cast({:queue, data}, state) do
    json = Jason.encode!(data)
    Redix.command(state[:redix], ["RPUSH", state[:queue], json])
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
