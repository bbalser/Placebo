defmodule Placebo.Meck do
  defmodule Stub do
    defstruct [:pid, :module, :function, :args_matcher, :args, :arity, :action, :expect?, :state]
  end

  def stub(module, function, args, action, expect?, pid) do
    arity = length(args)
    args_matcher = :meck_args_matcher.new(args)

    %Stub{
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
  end

  def stubs(stubs, module, function, arity, pid \\ nil)

  def stubs(stubs, module, function, arity, nil) do
    Map.get(stubs, module, [])
    |> Enum.filter(fn stub -> stub.function == function && stub.arity == arity end)
  end

  def stubs(stubs, module, function, arity, pid) do
    callers = callers(pid)

    Map.get(stubs, module, [])
    |> Enum.filter(fn stub -> stub.pid in callers && stub.function == function && stub.arity == arity end)
  end

  def num_calls(module, function, args, pids \\ [])

  def num_calls(module, function, args, []) do
    :meck.num_calls(module, function, args)
  end

  def num_calls(module, function, args, pids) do
    pids
    |> Enum.map(fn pid -> :meck.num_calls(module, function, args, pid) end)
    |> Enum.sum()
  end

  def history(module, pids \\ [])

  def history(module, []) do
    :meck.history(module)
  end

  def history(module, pids) do
    pids
    |> Enum.map(&:meck.history(module, &1))
    |> List.flatten()
  end

  def capture(history_position, module, function, args, arg_num, pids \\ [])

  def capture(history_position, module, function, args, arg_num, []) do
    :meck.capture(history_position, module, function, args, arg_num)
  rescue
    _ -> nil
  end

  def capture(history_position, module, function, args, arg_num, pids) do
    pids
    |> Enum.find_value(fn pid ->
      try do
        :meck.capture(history_position, module, function, args, arg_num, pid)
      rescue
        _ -> nil
      end
    end)
  end

  def mock_module(module, meck_options \\ []) do
    :meck.new(module, [:passthrough | meck_options])
  end

  def mock_function(module, function, arity) do
    default_handler = default_mock_handler(module, function, arity)
    :meck.expect(module, function, default_handler)
  end

  def unload() do
    :meck.unload()
  end

  def callers(nil), do: []

  def callers(pid) do
    callers =
      pid
      |> Process.info(:dictionary)
      |> get_in([Access.elem(1), :"$callers", default_value([])])

    List.flatten([pid] ++ [callers])
  end

  defp default_value(default) do
    fn
      :get, nil, next ->
        next.(default)

      :get, data, next ->
        data
        |> List.wrap()
        |> next.()
    end
  end

  defp default_mock_handler(module, function, arity) do
    var_args = Macro.generate_arguments(arity, :"Elixir")

    quote location: :keep do
      fn unquote_splicing(var_args) ->
        args = [unquote_splicing(var_args)]
        stubs = Placebo.Server.stubs(unquote(module), unquote(function), unquote(arity))

        case Enum.find(stubs, fn stub -> :meck_args_matcher.match(args, stub.args_matcher) end) do
          nil ->
            :meck.passthrough(args)

          stub ->
            {action_result, new_state} = Placebo.Action.invoke(stub.action, args, stub.state)
            Placebo.Server.update_stub_state(unquote(module), stub, new_state)
            action_result
        end
      end
    end
    |> Code.eval_quoted()
    |> elem(0)
  end
end
