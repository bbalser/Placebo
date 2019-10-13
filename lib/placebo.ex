defmodule Placebo do
  @moduledoc """
  Placebo is a mocking library based on [meck](http://eproxus.github.io/meck/).
  It is inspired by [RSpec](http://rspec.info/) and [Mock](https://github.com/jjh42/mock).
  All the functionality covered below is provided by meck.
  Placebo is just a pretty wrapper around the features of meck.

  To enable just use Placebo in your ExUnit tests
  ```
    defmodule SomeTests do
      use ExUnit.Case
      use Placebo

      ## some awesome tests

    end
  ```


  ## Stubbing

  ```
    allow Some.Module.hello("world"), return: "some value"

    or

    allow(Some.Module.hello("world")) |> return("some value")
  ```
  This will mock the module "Some.Module" and stub out the hello function with an argument of "world" to return "some value" when called.
  Any Elixir term can be returned using this syntax.

  If you want more dyanmic behavior you can have a function executed when the mock is called.
  ```
    allow Some.Module.hello(any()), exec: &String.upcase/1
    allow Some.Module.hello(any()), exec: fn arg -> String.upcase(arg) end

    or

    allow(Some.Module.hello(any())) |> exec(&String.upcase/1)
    allow(Some.Module.hello(any())) |> exec(fn arg -> String.upcase(arg) end)
  ```

  If you pass no arguments in the allow section the arguments to the anonymous function will be used for matching.
  ```
    allow Some.Module.hello, exec: fn 1 -> "One"
                                        2 -> "Two"
                                        _ -> "Everything else" end

    or

    allow(Some.Module.hello) |> exec(fn 1 -> "One"
                                        2 -> "Two"
                                        _ -> "Everything else" end)
  ```

  To return different values on subsequent calls use seq or loop
  ```
    allow Some.Module.hello(any()), seq: [1,2,3,4]
    allow Some.Module.hello(any()), loop: [1,2,3,4]

    or

    allow(Some.Module.hello(any())) |> seq([1,2,3,4])
    allow(Some.Module.hello(any())) |> loop([1,2,3,4])
  ```
  seq will return the last value for every call after the last one is called
  loop will continue to loop around the list after the last one is called

  # Argument Matching

  Any term passed in as an argument will be matched exactly.
  `Placebo.Matchers` provides several argument matchers to be used for more dynamic scenarios.
  If you need something custom you can pass a function to the is/1 matcher.
  ```
    allow Some.Module.hello(is(fn arg -> rem(arg,2) == 0 end)), return: "Even"

    or

    allow(Some.Module.hello(is(fn arg -> rem(arg,2) == 0 end))) |> return("Even")
  ```

  all mocks created by Placebo are automaticaly created with :merge_expects option.
  So multiple allow statements can be made for the same function and will match in the order defined.
  ```
    allow Some.Module.hello(is(fn arg -> rem(arg,2) == 0 end))), return: "Even"
    allow Some.Module.hello(any()), return: "Odd"

    or

    allow(Some.Module.hello(is(fn arg -> rem(arg,2) == 0 end)))) |> return("Even")
    allow(Some.Module.hello(any())) |> return("Odd")
  ```

  # Verification

  Verification is done with assert_called and refute_called.
  All argument matchers also work in the verification step.

  ```
    assert_called Some.Module.hello("world")
    assert_called Some.Module.hello("world"), once()
    assert_called Some.Module.hello("world"), times(2)
  ```

  if you use expect instead of allow for any scenario. The interaction will automatically be verified at the end of the test.
  ```
    expect Some.Module.hello("world"), return: "some value"

    or

    expect(Some.Module.hello("world")) |> return("some value")
  ```

  Failed verifications will automatically print out all recorded interactions with the mocked module.

  """

  defmacro __using__(_args) do
    quote do
      import Placebo
      import Placebo.Matchers
      import Placebo.Validators
      import Placebo.Actions
      require Placebo.Macros

      setup(context) do
        async? = Map.get(context, :async, false)

        if async? == false do
          Placebo.Server.clear()
        end

        on_exit(fn ->
          # mocks = Placebo.Server.get()
          mocks = %{}

          try do
            Map.values(mocks)
            |> List.flatten()
            |> Enum.each(fn expectation ->
              assert :meck.called(expectation.module, expectation.function, expectation.args),
                     Placebo.Helpers.failure_message(
                       expectation.module,
                       expectation.function,
                       expectation.args
                     )
            end)
          after
            if async? == false do
              Placebo.Server.clear()
            end
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
    record_expectation(module, f, args, opts, false)
  end

  defmacro expect({{:., _, [module, f]}, _, args}, opts \\ []) do
    record_expectation(module, f, args, opts, true)
  end

  defp record_expectation(module, function, args, opts, expect?) do
    quote bind_quoted: [
            module: module,
            function: function,
            args: args,
            arity: length(args),
            opts: opts,
            expect?: expect?,
            default_function: Placebo.Macros.handler_for(module, function, length(args))
          ] do
      # mock = %Placebo.Mock{
      #   module: module,
      #   function: function,
      #   args: args,
      #   opts: Keyword.get(opts, :meck_options, []),
      #   action: action
      # }

      action = Placebo.determine_action(opts)
      Placebo.Server.stub(module, function, args, action, expect?)
      :meck.expect(module, function, default_function)
    end
  end

  defmacro assert_called({{:., _, [module, f]}, _, args}, validator \\ :any) do
    quote bind_quoted: [module: module, f: f, args: args, validator: validator] do
      Placebo.Helpers.called?(module, f, args, validator)
      |> assert(Placebo.Helpers.failure_message(module, f, args))
    end
  end

  defmacro called?({{:., _, [module, f]}, _, args}, validator \\ :any) do
    quote bind_quoted: [module: module, f: f, args: args, validator: validator] do
      Placebo.Helpers.called?(module, f, args, validator)
    end
  end

  defmacro num_calls({{:., _, [module, f]}, _, args}) do
    quote bind_quoted: [module: module, f: f, args: args] do
      :meck.num_calls(module, f, args)
    end
  end

  defmacro refute_called({{:., _, [module, f]}, _, args}, validator \\ :any) do
    quote bind_quoted: [module: module, f: f, args: args, validator: validator] do
      Placebo.Helpers.called?(module, f, args, validator)
      |> refute(Placebo.Helpers.failure_message(module, f, args))
    end
  end

  def determine_action(opts) do
    cond do
      Keyword.has_key?(opts, :return) -> %Placebo.Action.Return{value: Keyword.get(opts, :return)}
      Keyword.has_key?(opts, :exec) -> %Placebo.Action.Exec{function: Keyword.get(opts, :exec)}
      Keyword.has_key?(opts, :seq) -> %Placebo.Action.Seq{values: Keyword.get(opts, :seq)}
      Keyword.has_key?(opts, :loop) -> %Placebo.Action.Loop{values: Keyword.get(opts, :loop)}
      true -> raise "No action specified in Placebo stub, #{inspect(opts)}"
    end
  end

  # def update_mock(%Placebo.Mock{} = mock) do
  #   if not Placebo.Server.is_mock?(mock.module) do
  #     :meck.new(mock.module, set_opts(mock.opts))
  #   end

  #   Placebo.Server.add_expectation(mock)
  # end

  # defp set_opts(opts) do
  #   case Enum.member?(opts, :passthrough) do
  #     true -> [:no_link | opts]
  #     false -> [:no_link, :merge_expects | opts]
  #   end
  # end

  # defdelegate unstub, to: Placebo.Server, as: :clear

  # def set_expectation(%Placebo.Mock{} = mock, {:return, value}) do
  #   Placebo.Actions.return(mock, value)
  # end

  # def set_expectation(%Placebo.Mock{} = mock, {:exec, function}) do
  #   Placebo.Actions.exec(mock, function)
  # end

  # def set_expectation(%Placebo.Mock{} = mock, {:seq, list}) do
  #   Placebo.Actions.seq(mock, list)
  # end

  # def set_expectation(%Placebo.Mock{} = mock, {:loop, list}) do
  #   Placebo.Actions.loop(mock, list)
  # end

  # def set_expectation(_mock, _keyword), do: nil

end
