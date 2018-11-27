# run from the project root with
# elixir --no-halt -r lib/*  examples/apply_every.exs

defmodule FpsCounter do
  @timeout Float.round(1_000_000 / 60) |> trunc

  def run do
    {:ok, pid} = Agent.start_link(fn -> System.monotonic_time(:microsecond) end)
    MicroTimer.apply_every(@timeout, &show_fps/1, [pid])
  end

  def show_fps(pid) do
    start = Agent.get(pid, & &1)
    fps = 1_000_000 / (System.monotonic_time(:microsecond) - start)
    IO.write("\rFPS: #{fps}")
    Agent.update(pid, fn _ -> System.monotonic_time(:microsecond) end)
  end
end

FpsCounter.run()
