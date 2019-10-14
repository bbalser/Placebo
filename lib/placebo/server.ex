defmodule Placebo.Server do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## CLIENT

  def set_async(async?), do: GenServer.cast(__MODULE__, {:async?, async?})

  def stub(module, function, args, action, expect?, default_function) do
    GenServer.call(__MODULE__, {:stub, module, function, args, action, expect?, default_function})
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

  defmodule Stub do
    defstruct [:pid, :module, :function, :args_matcher, :args, :arity, :action, :expect?, :state]
  end

  defmodule State do
    defstruct stubs: %{}, async?: false, related_pids: %{}
  end

  def init(_args) do
    {:ok, %State{}}
  end

  def handle_call({:stub, module, function, args, action, expect?, default_function}, {pid, _}, state) do
    arity = length(args)
    args_matcher = :meck_args_matcher.new(args)

    stub = %Stub{
      pid: pid,
      module: module,
      function: function,
      args_matcher: args_matcher,
      args: args,
      arity: arity,
      action: action,
      expect?: expect?,
      state: %{}
    }

    stubs = Map.update(state.stubs, module, [stub], fn current -> [stub | current] end)

    unless Map.has_key?(state.stubs, module) do
      :meck.new(module, [:passthrough])
      :meck.expect(module, function, default_function)
    end

    reply(:ok, %{state | stubs: stubs})
  end

  def handle_call({:stubs, module, function, arity}, {caller_pid, _}, %{async?: true} = state) do
    ancestors = ancestors(caller_pid)

    Map.get(state.stubs, module, [])
    |> Enum.filter(fn stub -> stub.pid in ancestors && stub.function == function && stub.arity == arity end)
    |> reply(state)
  end

  def handle_call({:stubs, module, function, arity}, _from, state) do
    Map.get(state.stubs, module, [])
    |> Enum.filter(fn stub -> stub.function == function && stub.arity == arity end)
    |> reply(state)
  end

  def handle_call({:expects, test_pid}, _from, state) do
    Map.values(state.stubs)
    |> List.flatten()
    |> Enum.filter(fn stub -> stub.pid == test_pid && stub.expect? == true end)
    |> reply(state)
  end

  def handle_call({:update, module, stub, new_state}, {caller_pid, _}, state) do
    [test_pid | descendents] = ancestors(caller_pid) |> Enum.reverse()

    new_stubs =
      Map.update!(state.stubs, module, fn stubs ->
        index = Enum.find_index(stubs, fn entry -> entry == stub end)
        List.replace_at(stubs, index, %{stub | state: new_state})
      end)

    reply(:ok, %{state | stubs: new_stubs, related_pids: Map.put(state.related_pids, test_pid, descendents)})
  end

  def handle_call({:num_calls, module, function, args, caller_pid}, _from, %{async?: true} = state) do
    [caller_pid | Map.get(state.related_pids, caller_pid, [])]
    |> Enum.map(fn pid -> :meck.num_calls(module, function, args, pid) end)
    |> Enum.sum()
    |> reply(state)
  end

  def handle_call({:num_calls, module, function, args, _caller_pid}, _from, state) do
    :meck.num_calls(module, function, args)
    |> reply(state)
  end

  def handle_call({:history, module, caller_pid}, _from, %{async?: true} = state) do
    [caller_pid | Map.get(state.related_pids, caller_pid, [])]
    |> Enum.map(fn pid -> :meck.history(module, pid) end)
    |> List.flatten()
    |> reply(state)
  end

  def handle_call({:history, module, _caller_pid}, _from, state) do
    :meck.history(module)
    |> reply(state)
  end

  def handle_call(
        {:capture, history_position, module, function, args, arg_num, caller_pid},
        _from,
        %{async?: true} = state
      ) do
    [caller_pid | Map.get(state.related_pids, caller_pid, [])]
    |> Enum.map(fn pid ->
      try do
        :meck.capture(history_position, module, function, args, arg_num, pid)
      rescue
        _ -> nil
      end
    end)
    |> Enum.find(fn c -> c != nil end)
    |> case do
      nil -> reply({:error, :not_found}, state)
      c -> reply({:ok, c}, state)
    end
  end

  def handle_call({:capture, history_position, module, function, args, arg_num, _caller_pid}, _from, state) do
    capture = :meck.capture(history_position, module, function, args, arg_num)
    reply({:ok, capture}, state)
  rescue
    error -> reply({:error, error}, state)
  end

  def handle_call(:clear, _from, _state) do
    :meck.unload()

    reply(:ok, %State{})
  end

  def handle_cast({:async?, async?}, state) do
    noreply(%{state | async?: async?})
  end

  defp ancestors(pid) do
    ancestors =
      pid
      |> Process.info()
      |> Keyword.get(:dictionary)
      |> Keyword.get(:"$ancestors", [])

    [pid | ancestors]
  end

  defp noreply(new_state), do: {:noreply, new_state}
  defp reply(value, new_state), do: {:reply, value, new_state}
end
