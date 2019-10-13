defmodule Placebo.Server do
  use GenServer
  import Placebo.Macros, only: [handler_for: 3]

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## CLIENT

  def set_async(async?), do: GenServer.cast(__MODULE__, {:async?, async?})

  def stub(module, function, args, action, expect?) do
    GenServer.call(__MODULE__, {:stub, module, function, args, action, expect?})
  end

  def stubs(module, function, arity) do
    GenServer.call(__MODULE__, {:stubs, module, function, arity})
  end

  def update_stub_state(module, stub, state) do
    GenServer.cast(__MODULE__, {:update, module, stub, state})
  end

  def clear do
    :ok
  end
  # def clear, do: GenServer.call(__MODULE__, :clear)

  # def get, do: GenServer.call(__MODULE__, :get)

  # def is_mock?(module), do: GenServer.call(__MODULE__, {:is_new, module})

  # def add_expectation(%Placebo.Mock{} = mock) do
  #   GenServer.cast(__MODULE__, {:add, mock})
  # end

  ## SERVER

  defmodule Stub do
    defstruct [:pid, :function, :args, :action, :expect?, :state]
  end

  defmodule State do
    defstruct stubs: %{}, async?: false
  end

  def init(_args) do
    {:ok, %State{}}
  end

  def handle_call({:stub, module, function, args, action, expect?}, {pid, _}, state) do
    arity = length(args)
    stub = %Stub{pid: pid, function: function, args: args, action: action, expect?: expect?, state: %{}}
    stubs = Map.update(state.stubs, module, [stub], fn current -> [stub | current] end)

    unless Map.has_key?(state.stubs, module) do
      :meck.new(module, [:passthrough]) #TODO no_link? not sure why I neede that before
    end

    reply(:ok, %{state | stubs: stubs})
  end

  def handle_call({:stubs, module, function, arity}, {_pid, _}, state) do
    Map.get(state.stubs, module, [])
    |> Enum.filter(fn stub -> stub.function == function && length(stub.args) == arity end)
    |> reply(state)
  end

  # def handle_call(:get, _from, state) do
  #   reply(state, state)
  # end

  # def handle_call({:is_new, module}, _from, state) do
  #   Map.has_key?(state, module)
  #   |> reply(state)
  # end

  # def handle_call(:clear, _from, _state) do
  #   :meck.unload()

  #   reply(:ok, Map.new())
  # end

  def handle_cast({:async?, async?}, state) do
    noreply(%{state | async?: async?})
  end

  def handle_cast({:update, module, stub, new_state}, state) do
    new_stubs = Map.update!(state.stubs, module, fn stubs ->
      index = Enum.find_index(stubs, fn entry -> entry == stub end)
      List.replace_at(stubs, index, %{stub | state: new_state})
    end)

    noreply(%{state | stubs: new_stubs})
  end

  # def handle_cast({:add, %Placebo.Mock{} = mock}, state) do
  #   Map.put(state, mock.module, determine_value(state, mock))
  #   |> noreply()
  # end

  # defp determine_value(state, mock) do
  #   current_value = Map.get(state, mock.module, [])

  #   case mock.action do
  #     :expect -> [%Placebo.Expectation{module: mock.module, function: mock.function, args: mock.args} | current_value]
  #     _ -> current_value
  #   end
  # end


  defp noreply(new_state), do: {:noreply, new_state}
  defp reply(value, new_state), do: {:reply, value, new_state}
end
