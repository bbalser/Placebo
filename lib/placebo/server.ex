defmodule Placebo.Server do
  use GenServer
  alias Placebo.Meck

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## CLIENT

  def set_async(async?), do: GenServer.cast(__MODULE__, {:async?, async?})

  def stub(module, function, args, action, expect?, meck_options \\ []) do
    GenServer.call(__MODULE__, {:stub, module, function, args, action, expect?, meck_options})
  end

  def stubs(module, function, arity) do
    GenServer.call(__MODULE__, {:stubs, module, function, arity})
  end

  def expects(test_pid \\ self()) do
    GenServer.call(__MODULE__, {:expects, test_pid})
  end

  def update_stub_state(module, stub, state) do
    GenServer.call(__MODULE__, {:update, module, stub, state})
  end

  def num_calls(module, function, args, caller \\ self()) do
    GenServer.call(__MODULE__, {:num_calls, module, function, args, caller})
  end

  def history(module, caller \\ self()) do
    GenServer.call(__MODULE__, {:history, module, caller})
  end

  def capture(history_position, module, function, args, arg_num, caller \\ self()) do
    GenServer.call(__MODULE__, {:capture, history_position, module, function, args, arg_num, caller})
  end

  def clear, do: GenServer.call(__MODULE__, :clear)

  ## SERVER

  defmodule State do
    defstruct stubs: %{}, async?: false, related_pids: %{}
  end

  def init(_args) do
    {:ok, %State{}}
  end

  def handle_call({:stub, module, function, args, action, expect?, meck_options}, {pid, _}, state) do
    stub = Meck.stub(module, function, args, action, expect?, pid)

    unless Map.has_key?(state.stubs, module) do
      Meck.mock_module(module, meck_options)
    end

    unless is_function_mocked(state, module, function) do
      Meck.mock_function(module, function, stub.arity)
    end

    stubs = Map.update(state.stubs, module, [stub], fn current -> [stub | current] end)
    reply(:ok, %{state | stubs: stubs})
  end

  def handle_call({:stubs, module, function, arity}, {caller_pid, _}, %{async?: true} = state) do
    Meck.stubs(state.stubs, module, function, arity, caller_pid)
    |> reply(state)
  end

  def handle_call({:stubs, module, function, arity}, _from, state) do
    Meck.stubs(state.stubs, module, function, arity)
    |> reply(state)
  end

  def handle_call({:expects, test_pid}, _from, state) do
    Map.values(state.stubs)
    |> List.flatten()
    |> Enum.filter(fn stub -> stub.pid == test_pid && stub.expect? == true end)
    |> reply(state)
  end

  def handle_call({:update, module, stub, new_state}, {caller_pid, _}, state) do
    [test_pid | descendents] = Meck.ancestors(caller_pid) |> Enum.reverse()

    new_stubs =
      Map.update!(state.stubs, module, fn stubs ->
        index = Enum.find_index(stubs, fn entry -> entry == stub end)
        List.replace_at(stubs, index, %{stub | state: new_state})
      end)

    reply(:ok, %{state | stubs: new_stubs, related_pids: Map.put(state.related_pids, test_pid, descendents)})
  end

  def handle_call({:num_calls, module, function, args, caller_pid}, _from, %{async?: true} = state) do
    pids = [caller_pid | Map.get(state.related_pids, caller_pid, [])]

    Meck.num_calls(module, function, args, pids)
    |> reply(state)
  end

  def handle_call({:num_calls, module, function, args, _caller_pid}, _from, state) do
    Meck.num_calls(module, function, args)
    |> reply(state)
  end

  def handle_call({:history, module, caller_pid}, _from, %{async?: true} = state) do
    pids = [caller_pid | Map.get(state.related_pids, caller_pid, [])]

    Meck.history(module, pids)
    |> reply(state)
  end

  def handle_call({:history, module, _caller_pid}, _from, state) do
    Meck.history(module)
    |> reply(state)
  end

  def handle_call(
        {:capture, history_position, module, function, args, arg_num, caller_pid},
        _from,
        %{async?: true} = state
      ) do
    pids = [caller_pid | Map.get(state.related_pids, caller_pid, [])]
    case Meck.capture(history_position, module, function, args, arg_num, pids) do
      nil -> {:error, :not_found}
      capture -> {:ok, capture}
    end
    |> reply(state)
  end

  def handle_call({:capture, history_position, module, function, args, arg_num, _caller_pid}, _from, state) do
    case Meck.capture(history_position, module, function, args, arg_num) do
      nil -> {:error, :not_found}
      capture -> {:ok, capture}
    end
    |> reply(state)
  end

  def handle_call(:clear, _from, _state) do
    Meck.unload()

    reply(:ok, %State{})
  end

  def handle_cast({:async?, async?}, state) do
    noreply(%{state | async?: async?})
  end

  defp is_function_mocked(state, module, function) do
    Map.get(state.stubs, module, [])
    |> Enum.any?(fn stub -> stub.function == function end)
  end

  defp noreply(new_state), do: {:noreply, new_state}
  defp reply(value, new_state), do: {:reply, value, new_state}
end
