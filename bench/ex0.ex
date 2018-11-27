defmodule MicroTimerBenchNoAdjust do
  def usleep(timeout) when is_integer(timeout) and timeout > 0 do
    do_usleep(timeout)

    receive do
      :done -> :ok
    end
  end

  defp do_usleep(timeout) when timeout > 2_000 do
    ms_timeout = div(timeout, 1_000) - 1
    us_timeout = timeout - ms_timeout * 1_000

    Process.sleep(ms_timeout)

    do_usleep(System.monotonic_time(:microsecond), us_timeout)
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
    IO.write(:stderr, "Ex0 started processing data...\n")

    File.stream!(Path.expand(file))
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Stream.each(fn {timeout, index} ->
      if index > 0 and rem(index, 100) == 0 do
        IO.write(:stderr, "\rEx0 processed #{index} lines...")
      end

      {time, _} =
        :timer.tc(fn ->
          usleep(timeout)
        end)

      r = :io_lib.format("~f", [(time - timeout) / timeout])
      IO.puts("#{time};#{time - timeout};#{r}")
    end)
    |> Stream.run()

    IO.write(:stderr, "\nEx0 done processing!\n")
  end
end
