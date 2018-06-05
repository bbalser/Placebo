defmodule Mockit.Dummy do
  defmodule Exception do
    defexception [:message]
  end

  def get(_), do: "&get/1"
  def get(_, _), do: "&get/2"
end
