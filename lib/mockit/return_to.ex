defmodule Mockit.ReturnTo do

  def to_return({:loop, list}, {_, module, f, args}) do
    mock(module)
    :meck.expect(module, f, args, :meck.loop(list))
  end

  def to_return({:sequence, list}, {_, module, f, args}) do
    mock(module)
    :meck.expect(module, f, args, :meck.seq(list))
  end

  def to_return(function, {_, module, f, _args}) when is_function(function) do
    mock(module)
    :meck.expect(module, f, function)
  end

  def to_return(term, {_, module, f, args}) do
    mock(module)
    :meck.expect(module, f, args, :meck.val(term))
  end

  defp mock(module) do
    if not is_mocked?(module) do
      :meck.new(module)
    end
  end

  defp is_mocked?(module) do
    Agent.get_and_update(Mockit.Agent, fn state ->
      {MapSet.member?(state, module), MapSet.put(state, module)}
    end)
  end

end
