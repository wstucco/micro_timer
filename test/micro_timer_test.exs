defmodule MicroTimerTest do
  use ExUnit.Case
  doctest MicroTimer

  test "usleep/1" do
    assert MicroTimer.usleep(1) == :ok
  end

  test "usleep/1 accpets only integers" do
    assert_raise FunctionClauseError, fn ->
      MicroTimer.usleep(1.1) == :ok
    end
  end
end
