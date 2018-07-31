defmodule QTest do
  use ExUnit.Case
  doctest Q

  test "greets the world" do
    assert Q.hello() == :world
  end
end
