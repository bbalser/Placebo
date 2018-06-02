defmodule Mockit do
  defmacro __using__(_args) do
    quote do
      import Mockit
      import Mockit.Matchers
      import Mockit.RetSpecs
      import Mockit.Validators

      setup_all do
        Agent.start(fn -> Map.new() end, name: Mockit.Agent)

        on_exit(fn -> Agent.stop(Mockit.Agent) end)
        :ok
      end

      setup do
        on_exit(fn ->

          mocks = Agent.get_and_update(Mockit.Agent, fn s -> {Map.values(s), Map.new()} end)

          try do
            Enum.filter(mocks, fn mock -> mock.action == :expect end)
            |> Enum.each(fn mock ->
              assert :meck.called(mock.module, mock.function, mock.args), Mockit.Helpers.format_history(mock.module)
            end)
          after
            Enum.each(mocks, fn mock -> :meck.unload(mock.module) end)
          end

        end)

        :ok
      end
    end
  end

  defmacro capture({{:., _, [module, f]}, _, args}, arg_num) do
    quote do
      :meck.capture(:first, unquote(module), unquote(f), unquote(args), unquote(arg_num))
    end
  end

  defmacro capture(history_position, {{:., _, [module, f]}, _, args}, arg_num) do
    quote do
      :meck.capture(
        unquote(history_position),
        unquote(module),
        unquote(f),
        unquote(args),
        unquote(arg_num)
      )
    end
  end

  defmacro allow({{:., _, [module, f]}, _, args}, opts \\ []) do
    record_expectation(module, f, args, opts, :allow)
  end

  defmacro expect({{:., _, [module, f]}, _, args}, opts \\ []) do
    record_expectation(module,f, args, opts, :expect)
  end

  defp record_expectation(module, function, args, opts, action) do
    quote bind_quoted: [module: module, function: function, args: args, opts: opts, action: action] do
      mock = %Mockit.Mock{module: module, function: function, args: args, opts: opts, action: action}
      {Mockit.To, mock}
    end
  end

  defmacro assert_called({{:., _, [module, f]}, _, args}, validator \\ :any) do
    quote bind_quoted: [module: module, f: f, args: args, validator: validator] do
      result = case validator do
          {:times, n} -> n == :meck.num_calls(module, f, args)
          _ -> :meck.called(module, f, args)
        end

      assert(result, Mockit.Helpers.format_history(module))
    end
  end

  defmacro refute_called({{:., _, [module, f]}, _, args}, validator \\ :any) do
    quote bind_quoted: [module: module, f: f, args: args, validator: validator] do
      result =
        case validator do
          {:times, n} -> n == :meck.num_calls(module, f, args)
          _ -> :meck.called(module, f, args)
        end

      refute(result, Mockit.Helpers.format_history(module))
    end
  end

end
