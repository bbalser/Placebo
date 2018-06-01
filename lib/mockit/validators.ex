defmodule Mockit.Validators do

  def once(), do: :once
  def times(n), do: {:times, n}

end
