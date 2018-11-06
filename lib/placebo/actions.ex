defmodule Placebo.Actions do
  def return(%Placebo.Mock{} = mock, value) do
    :meck.expect(mock.module, mock.function, mock.args, :meck.val(value))
  end

  def exec(%Placebo.Mock{} = mock, function) do
    case Enum.count(mock.args) do
      0 -> :meck.expect(mock.module, mock.function, function)
      _ -> :meck.expect(mock.module, mock.function, mock.args, :meck.exec(function))
    end
  end

  def seq(%Placebo.Mock{} = mock, list) do
    :meck.expect(mock.module, mock.function, mock.args, :meck.seq(list))
  end

  def loop(%Placebo.Mock{} = mock, list) do
    :meck.expect(mock.module, mock.function, mock.args, :meck.loop(list))
  end
end
