defmodule Placebo.Dummy do
  @moduledoc false

  defmodule Exception do
    defexception [:message]
  end

  def get(_), do: "&get/1"
  def get(_, _), do: "&get/2"
end
