defmodule MicroTimerTest do
  use ExUnit.Case
  use ExUnitProperties
  use TestMacros
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

  test "apply_after/3 invoke a function with args after `timeout` microseconds" do
    pid = MicroTimer.apply_after(250, fn msg, parent -> send(parent, msg) end, [:msg, self()])
    assert_received_after(250, :msg)
    refute Process.alive?(pid)
  end

  test "apply_after/3 invoke Module.function with args after `timeout` microseconds" do
    defmodule B do
      def f(msg, parent), do: send(parent, msg)
    end

    pid = MicroTimer.apply_after(250, {B, :f}, [:msg, self()])
    assert_received_after(250, :msg)
    refute Process.alive?(pid)
  end

  test "apply_every/2" do
    assert MicroTimer.apply_every(1, fn -> nil end) |> is_pid()
  end

  test "apply_every/3" do
    assert MicroTimer.apply_every(1, fn -> nil end, []) |> is_pid()
  end

  test "apply_every/2 invoke a function every `timeout` microseconds" do
    parent = self()
    pid = MicroTimer.apply_every(250, fn -> send(parent, :msg) end)

    assert_received_every(250, :msg)
    MicroTimer.cancel_timer(pid)
    refute Process.alive?(pid)
  end

  test "apply_every/3 invoke a function with args after `timeout` microseconds" do
    pid = MicroTimer.apply_every(250, fn msg, parent -> send(parent, msg) end, [:msg, self()])

    assert_received_every(250, :msg)

    MicroTimer.cancel_timer(pid)
    refute Process.alive?(pid)
  end

  test "apply_every/3 invoke Module.function with args after `timeout` microseconds" do
    defmodule C do
      def f(msg, parent), do: send(parent, msg)
    end

    pid = MicroTimer.apply_every(250, {C, :f}, [:msg, self()])
    assert_received_every(250, :msg)

    MicroTimer.cancel_timer(pid)
    refute Process.alive?(pid)
  end

  test "send_after/2" do
    assert MicroTimer.send_after(1, :msg) |> is_pid()
  end

  test "send_after/3" do
    assert MicroTimer.send_after(1, :msg, self()) |> is_pid()
  end

  test "send_after/3 sends a message to `pid` after `timeout` microseconds" do
    MicroTimer.send_after(250, :msg, self())
    assert_received_after(250, :msg)
  end

  test "send_after/3 returns a `pid` that can be cancelled" do
    pid = MicroTimer.send_after(2_000, :msg, self())
    MicroTimer.cancel_timer(pid)
    refute_receive :msg, 2
    refute Process.alive?(pid)
  end

  test "send_every/2" do
    assert MicroTimer.send_every(1, :msg) |> is_pid()
  end

  test "send_every/3" do
    assert MicroTimer.send_every(1, :msg, self()) |> is_pid()
  end

  test "send_every/3 sends a message to `pid` every `timeout` microseconds" do
    pid = MicroTimer.send_every(2_000, :msg, self())

    assert_received_every(250, :msg)

    MicroTimer.cancel_timer(pid)
    refute Process.alive?(pid)
  end

  test "send_every/3 returns a `pid` that can be cancelled" do
    pid = MicroTimer.send_every(2_000, :msg, self())
    MicroTimer.cancel_timer(pid)
    refute_receive :msg, 2
    refute Process.alive?(pid)
  end

  test "cancel_timer/1" do
    pid = MicroTimer.apply_every(250, fn -> nil end)
    assert MicroTimer.cancel_timer(pid) == true
  end

  test "cancel_timer/1 kills the timer identified by `pid`" do
    pid = MicroTimer.apply_every(250, fn parent -> send(parent, :msg) end, [self()])
    assert MicroTimer.cancel_timer(pid) == true
    refute Process.alive?(pid)
    refute_receive :msg, 1
  end
end
