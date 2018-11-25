Application.ensure_started(:stream_data)

defmodule TestMacros do
  defmacro __using__(_opts) do
    quote do
      import TestMacros
    end
  end

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

  defmacro assert_received_every(timeout, msg, runs \\ 10) do
    quote do
      start = System.monotonic_time(:microsecond)
      limit = unquote(runs) * 10

      n =
        Enum.reduce_while(1..100, 0, fn
          _, unquote(runs) ->
            {:halt, unquote(runs)}

          _, acc ->
            receive do
              unquote(msg) ->
                {:cont, acc + 1}
            after
              1_000 -> {:halt, :err}
            end
        end)

      assert n == unquote(runs)
      assert System.monotonic_time(:microsecond) - start >= unquote(timeout) * unquote(runs)
    end
  end
end

ExUnit.start()
