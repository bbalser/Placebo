defmodule Placebo.Server do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, Map.new()}
  end

  ## CLIENT

  def clear, do: GenServer.cast(__MODULE__, :clear)

  def get, do: GenServer.call(__MODULE__, :get)

  def is_mock?(module), do: GenServer.call(__MODULE__, {:is_new, module})

  def add_expectation(%Placebo.Mock{} = mock) do
    GenServer.cast(__MODULE__, {:add, mock})
  end

  ## SERVER

  def handle_call(:get, _from, state) do
    reply(state, state)
  end

  def handle_call({:is_new, module}, _from, state) do
    Map.has_key?(state, module)
    |> reply(state)
  end

  def handle_cast(:clear, _state) do
    :meck.unload()

    Map.new()
    |> noreply()
  end

  def handle_cast({:add, %Placebo.Mock{} = mock}, state) do
    Map.put(state, mock.module, determine_value(state, mock))
    |> noreply()
  end

  defp determine_value(state, mock) do
    current_value = Map.get(state, mock.module, [])

    case mock.action do
      :expect -> [%Placebo.Expectation{module: mock.module, function: mock.function, args: mock.args} | current_value]
      _ -> current_value
    end
  end

  defp noreply(new_state), do: {:noreply, new_state}
  defp reply(value, new_state), do: {:reply, value, new_state}
end
