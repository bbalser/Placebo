defmodule PlaceboTest do
  use ExUnit.Case
  use Placebo
  use ExUnitProperties

  test "Can stub out static value" do
    allow Regex.regex?("one"), return: 1

    assert Regex.regex?("one") == 1
  end

  test "Can stub out static value, pipeline syntax" do
    allow(Regex.regex?("one")) |> return(1)

    assert Regex.regex?("one") == 1
  end

  test "expectations are merged" do
    allow Regex.regex?("one"), return: 1
    allow Regex.regex?("two"), return: 2

    assert Regex.regex?("one") == 1
    assert Regex.regex?("two") == 2
  end

  test "Can execute function but match on given args" do
    allow Regex.regex?("one"), exec: fn x -> x end
    allow Regex.regex?(any()), exec: fn _ -> :two end

    assert Regex.regex?("one") == "one"
    assert Regex.regex?("two") == :two
  end

  test "Can execute function, pipeline syntax" do
    allow(Regex.regex?("one")) |> exec(fn _ -> :one end)

    assert Regex.regex?("one") == :one
  end

  test "When no matcher given to mock with exec call, function args are matchers" do
    allow Regex.regex?(),
      exec: fn
        "one" -> 1
        "two" -> 2
      end

    assert Regex.regex?("one") == 1
    assert Regex.regex?("two") == 2
  end

  test "Can create sequence of stubs" do
    allow Regex.regex?(any()), seq: [1, 2, 3]

    assert Regex.regex?("one") == 1
    assert Regex.regex?("two") == 2
    assert Regex.regex?("three") == 3
    assert Regex.regex?("four") == 3
  end

  test "Can create sequence of stubs, pipeline syntax" do
    allow(Regex.regex?(any())) |> seq([1, 2, 3])

    assert Regex.regex?("one") == 1
    assert Regex.regex?("two") == 2
    assert Regex.regex?("three") == 3
    assert Regex.regex?("four") == 3
  end

  test "Can create loop of stubs" do
    allow Regex.regex?(any()), loop: [1, 2, 3]

    assert Regex.regex?("one") == 1
    assert Regex.regex?("two") == 2
    assert Regex.regex?("three") == 3
    assert Regex.regex?("four") == 1
  end

  test "Can create loop of stubs, pipeline syntax" do
    allow(Regex.regex?(any())) |> loop([1, 2, 3])

    assert Regex.regex?("one") == 1
    assert Regex.regex?("two") == 2
    assert Regex.regex?("three") == 3
    assert Regex.regex?("four") == 1
  end

  test "assert_called validate call to mock was made" do
    allow Regex.regex?(any()), return: true

    Regex.regex?("test")
    Regex.regex?("test")

    assert_called(Regex.regex?("test"))
  end

  test "called? validates call to mock was made" do
    allow Regex.regex?(any()), return: "Testing"

    Regex.regex?("anything")

    assert true == called?(Regex.regex?(any()))
  end

  test "num_calls return how many matched calls" do
    allow Regex.regex?(any()), return: "Testing"

    Regex.regex?("one")
    Regex.regex?("one")
    Regex.regex?("two")

    assert 2 == num_calls(Regex.regex?("one"))
    assert 1 == num_calls(Regex.regex?(is(fn p -> p == "two" end)))
  end

  test "num_calls returns how many matched calls based on function matcher" do
    allow Regex.regex?(any()), return: "Testing"

    Regex.regex?("two")

    assert 1 == num_calls(Regex.regex?(is(&(&1 == "two"))))
  end

  test "validator once" do
    allow Regex.regex?(any()), return: true

    Regex.regex?("test")
    Regex.regex?("test")

    refute_called(Regex.regex?("test"), once())
  end

  test "validator times" do
    allow Regex.regex?(any()), return: true

    Regex.regex?("test")
    Regex.regex?("test")

    assert_called(Regex.regex?("test"), times(2))
  end

  test "refute negative validator times" do
    allow Regex.regex?(any()), return: true

    Regex.regex?("test")

    refute_called(Regex.regex?("test"), times(2))
  end

  test "passthrough option" do
    allow Regex.run(~r/a/, "abc"), return: "Hello", meck_options: [:passthrough]

    assert Regex.run(~r/a/, "abc") == "Hello"
    assert Regex.run(~r/a/, "hey", return: :index) == nil
  end

  test "capture" do
    allow Regex.run(any(), any()), return: "Jerks"

    Regex.run(~r/a(b)/, "abcd")

    assert "abcd" == capture(Regex.run(any(), any()), 2)
  end

  test "capture from history" do
    allow Regex.run(any(), any()), return: "Hey"

    Regex.run(~r/one/, "abc")
    Regex.run(~r/two/, "xyz")

    assert "abc" == capture(Regex.run(:_, :_), 2)
    assert "xyz" == capture(2, Regex.run(:_, :_), 2)
  end

  test "expect does automatic verification of mock call" do
    expect Regex.regex?("a"), return: true
    assert Regex.regex?("a") == true
  end

  describe "property-based testing" do
    property "is possible with allow" do
      check all dummy_in <- string(:alphanumeric),
                dummy_out <- string(:alphanumeric) do
        allow Regex.regex?(any()), return: dummy_out
        assert Regex.regex?(dummy_in) == dummy_out

        Placebo.unstub()
      end
    end

    property "is possible with expect" do
      check all dummy_in <- string(:alphanumeric),
                dummy_out <- string(:alphanumeric) do
        expect Regex.regex?(any()), return: dummy_out
        assert Regex.regex?(dummy_in) == dummy_out

        Placebo.unstub()
      end
    end
  end
end
