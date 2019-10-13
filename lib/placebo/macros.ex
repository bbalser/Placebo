defmodule Placebo.Macros do
  defmacro matcher(name, do: block) do
    if references_input_variable?(block) do
      quote do
        def unquote(name)(var!(input)) do
          :meck.is(fn var!(arg) -> unquote(block) end)
        end
      end
    else
      quote do
        def unquote(name)() do
          :meck.is(fn var!(arg) -> unquote(block) end)
        end
      end
    end
  end

  defp references_input_variable?(block) do
    {_, result} =
      Macro.prewalk(block, false, fn exp, so_far ->
        {exp, match?({:input, _, _}, exp) || so_far}
      end)

    result
  end

  def handler_for(module, function, arity) do
    function_arguments = Macro.generate_arguments(arity, :"Elixir")
    quote location: :keep do
      fn unquote_splicing(function_arguments) ->
        args = [unquote_splicing(function_arguments)]
        stubs = Placebo.Server.stubs(unquote(module), unquote(function), unquote(arity))

        case Enum.find(stubs, fn stub -> :meck_args_matcher.match(args, stub.args_matcher) end) do
          nil -> :meck.passthrough(args)
          stub ->
            {action_result, new_state} = Placebo.Action.invoke(stub.action, args, stub.state)
            Placebo.Server.update_stub_state(unquote(module), stub, new_state)
            action_result
        end
      end
    end
  end
end
