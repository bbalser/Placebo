defmodule Mockit.To do
  alias Mockit.Mock

  def to({:return, value}, {_, %Mock{} = mock}) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.val(value))
  end

  def to({:exec, function}, {_, %Mock{} = mock}) do
    create_mock(mock)

    case Enum.count(mock.args) do
      0 -> :meck.expect(mock.module, mock.function, function)
      _ -> :meck.expect(mock.module, mock.function, mock.args, :meck.exec(function))
    end

  end

  def to({:sequence, list}, {_, %Mock{} = mock}) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.seq(list))
  end

  def to({:loop, list}, {_, %Mock{} = mock}) do
    create_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.loop(list))
  end


  # def to(function, {_, %Mock{} = mock}) when is_function(function) do
  #   create_mock(mock)
  #   :meck.expect(mock.module, mock.function, function)
  # end

  # def to(term, {_, %Mock{} = mock}) do
  #   create_mock(mock)
  #   :meck.expect(mock.module, mock.function, mock.args, :meck.val(term))
  # end

  defp create_mock(%Mock{} = mock) do
    if not is_mocked?(mock.module) do
      Agent.update(Mockit.Agent, fn s -> Map.put(s, mock.module, mock) end)
      :meck.new(mock.module, set_opts(mock.opts))
    end
  end

  defp is_mocked?(module) do
    Agent.get(Mockit.Agent, fn s -> Map.has_key?(s, module) end)
  end

  defp set_opts(opts) do
    case Enum.member?(opts, :passthrough) do
      true -> [:no_link | opts]
      false -> [:no_link, :merge_expects | opts]
    end
  end
end
