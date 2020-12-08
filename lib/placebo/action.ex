defprotocol Placebo.Action do
  @type action :: term
  @type args :: list
  @type state :: term

  @spec invoke(action, args, state) :: {term(), state}
  def invoke(action, args, state)
end

defmodule Placebo.Action.Return do
  defstruct [:value]

  defimpl Placebo.Action, for: Placebo.Action.Return do
    def invoke(%Placebo.Action.Return{value: value}, _args, state) do
      {value, state}
    end
  end
end

defmodule Placebo.Action.Exec do
  defstruct [:function]

  defimpl Placebo.Action, for: Placebo.Action.Exec do
    def invoke(%Placebo.Action.Exec{function: function}, args, state) do
      {apply(function, args), state}
    end
  end
end

defmodule Placebo.Action.Seq do
  defstruct [:values]

  defimpl Placebo.Action, for: Placebo.Action.Seq do
    def invoke(%Placebo.Action.Seq{values: values}, _args, state) do
      [head | tail] = Map.get(state, :remaining, values)

      case tail == [] do
        true -> {head, state}
        false -> {head, Map.put(state, :remaining, tail)}
      end
    end
  end
end

defmodule Placebo.Action.Loop do
  defstruct [:values]

  defimpl Placebo.Action, for: Placebo.Action.Loop do
    def invoke(%Placebo.Action.Loop{values: values}, _args, state) do
      [head | tail] = Map.get(state, :remaining, values)

      case tail == [] do
        true -> {head, Map.put(state, :remaining, values)}
        false -> {head, Map.put(state, :remaining, tail)}
      end
    end
  end
end
