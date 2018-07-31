defmodule Poller do
  require Logger

  def on_poll(data) do
    Logger.info("[POLLER] Got data: #{inspect(data, pretty: true)}")
  end
end

defmodule QTest do
  use ExUnit.Case
  require Logger
  doctest Q

  setup do
    {:ok, genserver} =
      Q.start_link(%{
        name: :q_test,
        queue: "q:test:queue",
        host: System.get_env("REDIS_IP"),
        port: 6379,
        pass: System.get_env("REDIS_PASS"),
        event_handler: &Poller.on_poll/1,
        poll: true
      })

    {:ok, process: genserver}
  end

  test "greets the world", %{process: process} do
    if System.get_env("REDIS_IP") != nil and System.get_env("REDIS_PASS") != nil do
      GenServer.cast(process, {:queue, %{"test" => true}})

      GenServer.cast(process, {:queue, %{"test2" => true}})

      Process.sleep(2500)
      assert true
    else
      Logger.warn("[TEST] No env, not testing!")
      assert true
    end
  end
end
