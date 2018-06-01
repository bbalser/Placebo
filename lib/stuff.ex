defmodule Stuff do

  def something(x), do: IO.inspect(x)

  def get(_), do: true
  def get(_,_), do: false

end
