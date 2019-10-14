defmodule Placebo.Helpers do
  def failure_message(module, function, args, caller \\ self()) do
    "Mock Verification Failed: #{output(module, function, args)}\nActual calls to Mock:\n#{format_history(module, caller)}"
  end

  defp output(module, function, args) do
    args_output = args |> Enum.map(&inspect/1) |> Enum.join(", ")
    "#{module}.#{function}(#{args_output})"
  end

  def format_history(module, caller \\ self()) do
    Placebo.Server.history(module, caller)
    |> Enum.map(&format_call/1)
    |> Enum.join("\n")
  end

  defp format_call({_pid, {m, f, a}, _result}) do
    "\t#{m}.#{to_string(f)}(#{inspect(a)})"
  end

  defp format_call({_pid, {m, f, a}, _error, _reason, _stack_trace}) do
    "\t#{m}.#{to_string(f)}(#{inspect(a)})"
  end

  def called?(module, function, args, validator) do
    num_calls = Placebo.Server.num_calls(module, function, args)

    case validator do
      {:times, n} -> n == num_calls
      _ -> num_calls > 0
    end
  end
end
