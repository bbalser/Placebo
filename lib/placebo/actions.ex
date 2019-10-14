defmodule Placebo.Actions do
  def return({module, function, args, expect?, meck_options}, value) do
    action = %Placebo.Action.Return{value: value}
    stub(module, function, args, action, expect?, meck_options)
  end

  def exec({module, function, args, expect?, meck_options}, exec_function) do
    action = %Placebo.Action.Exec{function: exec_function}
    stub(module, function, args, action, expect?, meck_options)
  end

  def seq({module, function, args, expect?, meck_options}, list) do
    action = %Placebo.Action.Seq{values: list}
    stub(module, function, args, action, expect?, meck_options)
  end

  def loop({module, function, args, expect?, meck_options}, list) do
    action = %Placebo.Action.Loop{values: list}
    stub(module, function, args, action, expect?, meck_options)
  end

  defp stub(module, function, args, action, expect?, meck_options) do
    Placebo.Server.stub(module, function, args, action, expect?, meck_options)
  end
end
