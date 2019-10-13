defmodule Placebo.Actions do
  def return({module, function, args, expect?, default_function}, value) do
    action = %Placebo.Action.Return{value: value}
    stub(module, function, args, action, expect?, default_function)
  end

  def exec({module, function, args, expect?, default_function}, exec_function) do
    action = %Placebo.Action.Exec{function: exec_function}
    stub(module, function, args, action, expect?, default_function)
  end

  def seq({module, function, args, expect?, default_function}, list) do
    action = %Placebo.Action.Seq{values: list}
    stub(module, function, args, action, expect?, default_function)
  end

  def loop({module, function, args, expect?, default_function}, list) do
    action = %Placebo.Action.Loop{values: list}
    stub(module, function, args, action, expect?, default_function)
  end

  defp stub(module, function, args, action, expect?, default_function) do
    Placebo.Server.stub(module, function, args, action, expect?, default_function)
  end
end
