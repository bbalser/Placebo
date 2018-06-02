defmodule Mockit.Helpers do

  def format_history(module) do
    history =
      :meck.history(module)
      |> Enum.map(fn {_pid, {m, f, a}, _ret} ->
        "\t#{m}.#{to_string(f)}(#{inspect(a)})"
      end)
      |> Enum.join("\n")

    "Mock Verification Failed:\nActual calls to Mock:\n#{history}\n"
  end

end
