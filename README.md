  #Placebo

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




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `placebo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:placebo, "~> 0.2.0", only: :test}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/placebo](https://hexdocs.pm/placebo).

