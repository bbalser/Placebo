defmodule Mockit.RetSpecs do
  def seq(list) when is_list(list) do
    {:sequence, list}
  end

  def loop(list) when is_list(list) do
    {:loop, list}
  end

  def return(value) do
    {:return, value}
  end

  def exec(function) when is_function(function) do
    {:exec, function}
  end
end
