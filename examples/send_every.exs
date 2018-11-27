# run from the project root with
# elixir --no-halt -r lib/*  examples/send_every.exs

defmodule FpsCounter do
  use GenServer

  @timeout Float.round(1_000_000 / 60) |> trunc

  def run do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_args) do
    MicroTimer.send_every(@timeout, :tick)
    {:ok, System.monotonic_time(:microsecond)}
  end

  def handle_info(:tick, state) do
    fps = 1_000_000 / (System.monotonic_time(:microsecond) - state)
    IO.write("\rFPS: #{fps}")
    {:noreply, System.monotonic_time(:microsecond)}
  end
end

FpsCounter.run()
