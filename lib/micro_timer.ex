defmodule MicroTimer do
  @moduledoc """
  A timer module with microsecond resolution.
  """

  @sleep_done :___usleep_done

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
    do_usleep(System.monotonic_time(:microsecond), timeout)

    receive do
      @sleep_done -> :ok
    end
  end

  def usleep(timeout) when is_integer(timeout) do
    :ok
  end



  defp do_usleep(start, timeout) do
    if System.monotonic_time(:microsecond) - start >= timeout do
      send(self(), @sleep_done)
    else
      do_usleep(start, timeout)
    end
  end
end
