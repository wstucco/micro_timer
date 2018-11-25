defmodule MicroTimerBenchAdjust do
  def usleep(timeout) when is_integer(timeout) and timeout > 0 do
    do_usleep(timeout)

    receive do
      :done -> :ok
    end
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
      send(self(), :done)
    else
      do_usleep(start, timeout)
    end
  end

  def run(file) do
    File.read!(Path.expand(file))
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.each(fn timeout ->
      {time, _} =
        :timer.tc(fn ->
          usleep(timeout)
        end)

      r = :io_lib.format("~f", [(time - timeout) / timeout])
      IO.puts("#{time};#{time - timeout};#{r}")
    end)
  end
end
