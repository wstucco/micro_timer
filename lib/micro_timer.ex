defmodule MicroTimer do
  @moduledoc """
  A timer module with microsecond resolution.
  """

  @sleep_done :___usleep_done
  @type executable :: {module(), atom()} | function()

  @doc """
  Suspend the current process for the given `timeout` and then returns `:ok`.

  `timeout` is the number of microsends to sleep as an integer.

  ## Examples

      iex> MicroTimer.usleep(250)
      :ok

  """
  @spec µsleep(non_neg_integer()) :: :ok
  defdelegate µsleep(timeout), to: __MODULE__, as: :usleep

  @spec usleep(non_neg_integer()) :: :ok
  def usleep(timeout) when is_integer(timeout) and timeout > 0 do
    do_usleep(timeout)

    receive do
      @sleep_done -> :ok
    end
  end

  def usleep(timeout) when is_integer(timeout) do
    :ok
  end

  @doc """
  Invokes the given `executable` after `timeout` microseconds with the list of
  arguments `args`.

  `executable` can either be the tuple `{Module, :function}`, an anonymous function
  or a function capture.

  Returns the `pid` of the timer.

  See also `cancel_timer/1`.

  ## Examples

      MicroTimer.apply_after(250, {Module. :function}, [])

      MicroTimer.apply_after(250, fn a -> a + 1 end, [1])

      iex> pid = MicroTimer.apply_after(250, fn arg -> arg end, [1])
      iex> is_pid(pid)
      true

  """

  @spec apply_after(non_neg_integer(), executable, [any]) :: pid()
  def apply_after(timeout, executable, args \\ [])

  def apply_after(timeout, {module, function}, args)
      when is_atom(module) and is_atom(function) do
    spawn(fn ->
      do_apply_after(timeout, {module, function}, args)
    end)
  end

  def apply_after(time, function, args) when is_function(function) do
    spawn(fn ->
      do_apply_after(time, function, args)
    end)
  end

  @doc """
  Invokes the given `executable` repeatedly every `timeout` microseconds with the list of
  arguments `args`.

  `executable` can either be the tuple `{Module, :function}`, an anonymous function
  or a function capture.

  Returns the `pid` of the timer.

  See also `cancel_timer/1`.

  ## Examples

      MicroTimer.apply_every(250, {Module. :function}, [])

      MicroTimer.apply_every(250, fn a -> a + 1 end, [1])

      iex> pid = MicroTimer.apply_every(250, fn arg -> arg end, [1])
      iex> is_pid(pid)
      true

  """
  @spec apply_every(non_neg_integer(), executable, [any]) :: pid()
  def apply_every(timeout, executable, args \\ [])

  def apply_every(timeout, {module, function}, args)
      when is_atom(module) and is_atom(function) do
    spawn(fn ->
      do_apply_every(timeout, {module, function}, args)
    end)
  end

  def apply_every(timeout, function, args) when is_function(function) do
    spawn(fn ->
      do_apply_every(timeout, function, args)
    end)
  end

  @doc """
  Cancel a timer `pid` created by `apply_after/2`, `apply_after/3`, `apply_every/2`
  or `apply_every/3`

  Always returns `true`

  ## Examples

      timer = MicroTimer.apply_every(250, {Module. :function}, [])
      MicroTimer.cancel_timer(timer)

      iex> pid = MicroTimer.apply_every(250, fn arg -> arg end, [1])
      iex> MicroTimer.cancel_timer(pid)
      iex> Process.alive?(pid)
      false

  """
  @spec cancel_timer(pid()) :: true
  def cancel_timer(pid) when is_pid(pid) do
    Process.exit(pid, :kill)
  end

  defp do_usleep(timeout) when timeout > 2_000 do
    ms_timeout = div(timeout, 1_000) - 1

    {real_sleep_time, _} =
      :timer.tc(fn ->
        Process.sleep(ms_timeout)
      end)

    do_usleep(System.monotonic_time(:microsecond), timeout - real_sleep_time)
  end

  defp do_usleep(timeout) do
    do_usleep(System.monotonic_time(:microsecond), timeout)
  end

  defp do_usleep(start, timeout) do
    if System.monotonic_time(:microsecond) - start >= timeout do
      send(self(), @sleep_done)
    else
      do_usleep(start, timeout)
    end
  end

  defp do_apply_after(timeout, {module, function}, args) do
    usleep(timeout)
    apply(module, function, args)
  end

  defp do_apply_after(timeout, function, args) do
    usleep(timeout)
    apply(function, args)
  end

  defp do_apply_every(timeout, executable, args) do
    do_apply_after(timeout, executable, args)
    do_apply_every(timeout, executable, args)
  end
end
