defmodule Mockit.Helpers do

  @delay 50

  def wait(fun) do
    wait(fun, 0)
  end

  defp wait(fun, elapsed) do
    case fun.() do
      true -> nil
      false ->
        Process.sleep(@delay)
        wait(fun, elapsed + @delay)
    end
  end

  def is_alive?(name) do
    case Process.whereis(name) do
      nil -> false
      pid -> Process.alive?(pid)
    end
  end

  def cleanup do
    Agent.get_and_update(Mockit.Agent, fn state -> {state, MapSet.new} end)
    |> Enum.map(fn module -> to_string(module) <> "_meck" |> String.to_atom end)
    |> Enum.each(fn module ->
      wait fn -> not is_alive?(module) end
    end)
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
