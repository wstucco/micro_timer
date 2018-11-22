defmodule MicroTimerTest do
  use ExUnit.Case
  doctest MicroTimer

  test "greets the world" do
    assert MicroTimer.hello() == :world
  end
end
