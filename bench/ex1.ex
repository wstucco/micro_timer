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
    IO.write(:stderr, "Ex1 started processing data...\n")

    File.stream!(Path.expand(file))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Stream.each(fn {timeout, index} ->
      if index > 0 and rem(index, 100) == 0 do
        IO.write(:stderr, "\rEx1 processed #{index} lines...")
      end

      {time, _} =
        :timer.tc(fn ->
          usleep(timeout)
        end)

      r = :io_lib.format("~f", [(time - timeout) / timeout])
      IO.puts("#{time};#{time - timeout};#{r}")
    end)
    |> Stream.run()

    IO.write(:stderr, "\nEx1 done processing!\n")
  end
end
