# run from the project root with
# elixir --no-halt -r lib/*  examples/apply_after.exs

defmodule FpsCounter do
  @timeout Float.round(1_000_000 / 60) |> trunc

  def run do
    MicroTimer.apply_after(@timeout, &show_fps/1, [System.monotonic_time(:microsecond)])
  end

  def show_fps(start) do
    fps = 1_000_000 / (System.monotonic_time(:microsecond) - start)
    IO.write("\rFPS: #{fps}")
    MicroTimer.apply_after(@timeout, &show_fps/1, [System.monotonic_time(:microsecond)])
  end
end

FpsCounter.run()
