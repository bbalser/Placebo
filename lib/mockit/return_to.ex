defmodule Mockit.ReturnTo do
  alias Mockit.Mock

  def to_return({:loop, list}, {_, %Mock{} = mock}) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.loop(list))
  end

  def to_return({:sequence, list}, {_, %Mock{} = mock}) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.seq(list))
  end

  def to_return(function, {_, %Mock{} = mock}) when is_function(function) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, function)
  end

  def to_return(term, {_, %Mock{} = mock}) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.val(term))
  end

  defp create_mock(%Mock{} = mock) do
    if not is_mocked?(mock.module) do
      Agent.update(Mockit.Agent, fn s -> Map.put(s, mock.module, mock) end)
      :meck.new(mock.module, [:no_link | mock.opts])
    end
  end

  defp is_mocked?(module) do
    Agent.get(Mockit.Agent, fn s -> Map.has_key?(s, module) end)
  end
end
