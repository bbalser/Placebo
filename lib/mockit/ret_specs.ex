defmodule Mockit.RetSpecs do
  def seq(list) when is_list(list) do
    {:sequence, list}
  end

  def loop(list) when is_list(list) do
    {:loop, list}
  end
end
