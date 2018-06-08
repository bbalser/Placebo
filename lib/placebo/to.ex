defmodule Placebo.To do
  alias Placebo.Mock

  def to({:return, value}, {_, %Mock{} = mock}) do
    update_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.val(value))
  end

  def to({:exec, function}, {_, %Mock{} = mock}) do
    update_mock(mock)

    case Enum.count(mock.args) do
      0 -> :meck.expect(mock.module, mock.function, function)
      _ -> :meck.expect(mock.module, mock.function, mock.args, :meck.exec(function))
    end

  end

  def to({:sequence, list}, {_, %Mock{} = mock}) do
    update_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.seq(list))
  end

  def to({:loop, list}, {_, %Mock{} = mock}) do
    update_mock(mock)
    :meck.expect(mock.module, mock.function, mock.args, :meck.loop(list))
  end

  defp update_mock(%Mock{} = mock) do
    if not Placebo.Server.is_mock?(mock.module) do
      :meck.new(mock.module, set_opts(mock.opts))
    end
    Placebo.Server.add_expectation(mock)
  end

  defp set_opts(opts) do
    case Enum.member?(opts, :passthrough) do
      true -> [:no_link | opts]
      false -> [:no_link, :merge_expects | opts]
    end
  end
end
