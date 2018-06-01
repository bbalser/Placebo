defmodule Mockit.Helpers do

  def cleanup do
    Agent.get_and_update(Mockit.Agent, fn state -> {state, MapSet.new} end)
    |> Enum.each(&:meck.unload/1)
  end

  def format_history(module) do
    history = :meck.history(module)
    |> Enum.map(fn {_pid, {m,f,a}, _ret} ->
      "\t#{m}.#{to_string(f)}(#{inspect a})"
    end)
    |> Enum.join("\n")
    "Actual calls to Mock:\n#{history}\n"
  end


end
