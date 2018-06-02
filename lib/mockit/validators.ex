defmodule Mockit.Validators do
  def once(), do: {:times, 1}
  def never(), do: {:times, 0}
  def times(n), do: {:times, n}
end
