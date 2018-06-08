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
    {_, result} = Macro.prewalk(block, false, fn exp, so_far ->
      { exp, match?({:input,_,_}, exp) || so_far }
    end)
    result
  end

end
