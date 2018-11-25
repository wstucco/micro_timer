defmodule MicroTimerTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest MicroTimer

  defmacro assert_received_after(timeout, msg) do
    quote do
      start = System.monotonic_time(:microsecond)

      receive do
        message ->
          assert message == unquote(msg)
          assert System.monotonic_time(:microsecond) - start >= unquote(timeout)
      after
        1_000 ->
          throw(:timeout)
      end
    end
  end

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

  test "apply_after/2" do
    assert MicroTimer.apply_after(1, fn -> nil end) |> is_pid()
  end

  test "apply_after/3" do
    assert MicroTimer.apply_after(1, fn -> nil end, []) |> is_pid()
  end

  test "apply_after/2 invoke a function after `timeout` microseconds" do
    parent = self()
    pid = MicroTimer.apply_after(250, fn -> send(parent, :msg) end)
    assert_received_after(250, :msg)
    refute Process.alive?(pid)
  end

  test "apply_after/3 invoke a function after `timeout` microseconds" do
    pid = MicroTimer.apply_after(250, fn msg, parent -> send(parent, msg) end, [:msg, self()])
    assert_received_after(250, :msg)
    refute Process.alive?(pid)
  end

  test "apply_after/2 invoke Module.function after `timeout` microseconds" do
    parent = self()

    defmodule A do
      @parent parent
      def f, do: send(@parent, :msg)
    end

    pid = MicroTimer.apply_after(250, {A, :f})
    assert_received_after(250, :msg)
    refute Process.alive?(pid)
  end

  test "apply_after/3 invoke Module.function after `timeout` microseconds" do
    defmodule B do
      def f(msg, parent), do: send(parent, msg)
    end

    pid = MicroTimer.apply_after(250, {B, :f}, [:msg, self()])
    assert_received_after(250, :msg)
    refute Process.alive?(pid)
  end
end
