defmodule Placebo.Actions do
  def return({module, function, args, expect?}, value) do
    action = %Placebo.Action.Return{value: value}
    stub(module, function, args, action, expect?)
  end

  def exec({module, function, args, expect?}, exec_function) do
    action = %Placebo.Action.Exec{function: exec_function}
    stub(module, function, args, action, expect?)
  end

  def seq({module, function, args, expect?}, list) do
    action = %Placebo.Action.Seq{values: list}
    stub(module, function, args, action, expect?)
  end

  def loop({module, function, args, expect?}, list) do
    action = %Placebo.Action.Loop{values: list}
    stub(module, function, args, action, expect?)
  end

  defp stub(module, function, args, action, expect?) do
    Placebo.Server.stub(module, function, args, action, expect?)
  end
end
