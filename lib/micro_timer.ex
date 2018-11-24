defmodule MicroTimer do
  @moduledoc """
  A timer module with microsecond resolution.
  """

  @doc """
  Suspend the current process for the given `timeout` and then returns `:ok`.

  `timeout` is the number of microsends to sleep as an integer.

  ## Examples

      iex> MicroTimer.usleep(250)
      :ok

  """

  defdelegate µsleep(timeout), to: __MODULE__, as: :usleep

  @spec usleep(non_neg_integer()) :: :ok
  def usleep(timeout) when is_integer(timeout) and timeout > 0 do
    :ok
  end

  def usleep(timeout) when is_integer(timeout) do
    :ok
  end
end
