defmodule PlaceboTest do
  use ExUnit.Case
  use Placebo

  test "Can stub out static value" do
    allow Placebo.Dummy.get(1), return: "Hello"

    assert Placebo.Dummy.get(1) == "Hello"
  end

  test "Can stub out static value, pipeline syntax" do
    allow(Placebo.Dummy.get(1)) |> return("Hello")

    assert Placebo.Dummy.get(1) == "Hello"
  end

  test "expectations are merged" do
    allow Placebo.Dummy.get("a"), return: "A"
    allow Placebo.Dummy.get(any()), return: "B"

    assert Placebo.Dummy.get("a") == "A"
    assert Placebo.Dummy.get("Zebra") == "B"
  end

  test "Can execute function but match on given args" do
    allow Placebo.Dummy.get("a"), exec: fn _ -> "One" end
    allow Placebo.Dummy.get(any()), return: "Two"

    assert Placebo.Dummy.get("a") == "One"
    assert Placebo.Dummy.get("b") == "Two"
  end

  test "Can execute function, pipeline syntax" do
    allow(Placebo.Dummy.get("a")) |> exec(fn _ -> "One" end)

    assert Placebo.Dummy.get("a") == "One"
  end

  test "When no matcher given to mock with exec call, function args are matchers" do
    allow Placebo.Dummy.get, exec: fn "a" -> "One"
                                     "b" -> "Two" end

    assert Placebo.Dummy.get("a") == "One"
    assert Placebo.Dummy.get("b") == "Two"
  end

  test "Can create sequence of stubs" do
    allow Placebo.Dummy.get(any()), seq: [1, 2, 3]

    assert Placebo.Dummy.get("a") == 1
    assert Placebo.Dummy.get("b") == 2
    assert Placebo.Dummy.get("c") == 3
    assert Placebo.Dummy.get("d") == 3
  end

  test "Can create sequence of stubs, pipeline syntax" do
    allow(Placebo.Dummy.get(any())) |> seq([1, 2, 3])

    assert Placebo.Dummy.get("a") == 1
    assert Placebo.Dummy.get("b") == 2
    assert Placebo.Dummy.get("c") == 3
    assert Placebo.Dummy.get("d") == 3
  end

  test "Can create loop of stubs" do
    allow Placebo.Dummy.get(any()), loop: [1, 2, 3]

    assert Placebo.Dummy.get("a") == 1
    assert Placebo.Dummy.get("b") == 2
    assert Placebo.Dummy.get("c") == 3
    assert Placebo.Dummy.get("d") == 1
  end

  test "Can create loop of stubs, pipeline syntax" do
    allow(Placebo.Dummy.get(any())) |> loop([1, 2, 3])

    assert Placebo.Dummy.get("a") == 1
    assert Placebo.Dummy.get("b") == 2
    assert Placebo.Dummy.get("c") == 3
    assert Placebo.Dummy.get("d") == 1
  end

  test "assert_called validate call to mock was made" do
    allow Placebo.Dummy.get(any()), return: "Testing"

    Placebo.Dummy.get("a")
    Placebo.Dummy.get("a")

    assert_called(Placebo.Dummy.get("a"))
  end

  test "validator once" do
    allow Placebo.Dummy.get(any()), return: "Testing"

    Placebo.Dummy.get("a")
    Placebo.Dummy.get("a")

    refute_called(Placebo.Dummy.get("a"), once())
  end

  test "validator times" do
    allow Placebo.Dummy.get(any()), return: "Testing"

    Placebo.Dummy.get("a")
    Placebo.Dummy.get("a")

    assert_called(Placebo.Dummy.get("a"), times(2))
  end

  test "refute negative validator times" do
    allow Placebo.Dummy.get(any()), return: "Testing"

    Placebo.Dummy.get("a")

    refute_called(Placebo.Dummy.get("a"), times(2))
  end

  test "passthrough option" do
    allow Placebo.Dummy.get("b"), return: "Hello", meck_options: [:passthrough]

    assert Placebo.Dummy.get("b") == "Hello"
    assert Placebo.Dummy.get("a", "b") == "&get/2"
  end

  test "capture" do
    allow Placebo.Dummy.get(any(), any()), return: "Jerks"

    Placebo.Dummy.get("pizza", "hound-dog")

    assert "pizza" == capture(Placebo.Dummy.get(any(), any()), 1)
  end

  test "capture nth call in history" do
    allow Placebo.Dummy.get(any(), any()), return: "Cowbody"

    Placebo.Dummy.get("one", "two")
    Placebo.Dummy.get("three", "four")

    assert "two" == capture(Placebo.Dummy.get(:_, :_), 2)
    assert "four" == capture(2, Placebo.Dummy.get(:_, :_), 2)
  end

  test "expect does automatic verification of mock call" do
    expect Placebo.Dummy.get("a"), return: "Browns"

    assert Placebo.Dummy.get("a") == "Browns"
  end

end
