defmodule MicroTimerTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest MicroTimer

  test "usleep/1" do
    assert MicroTimer.usleep(1) == :ok
  end

  test "usleep/1 accpets only integers" do
    assert_raise FunctionClauseError, fn ->
      MicroTimer.usleep(1.1) == :ok
    end
  end

  test "usleep/1 sleeps for at leat `timeout` µs" do
    check all timeout <- positive_integer(), timeout < 1_000 do
      {elapsed_time, :ok} =
        :timer.tc(fn ->
          MicroTimer.usleep(timeout)
        end)

      assert elapsed_time >= timeout
    end
  end
end
