defmodule MockitTest do
  use ExUnit.Case
  use Mockit

  test "Can stub out static value" do
    allow(Stuff.get(1)).to_return "Hello"

    assert Stuff.get(1) == "Hello"
  end

  test "Can stub out using a anonymous function" do
    allow(Stuff.get).to_return fn 1 -> "Hello"
                                  2 -> "Bye" end

    assert Stuff.get(1) == "Hello"
    assert Stuff.get(2) == "Bye"
  end

  test "Can match any arguments" do
    allow(Stuff.get(:_)).to_return "Jerks"

    assert Stuff.get("a") == "Jerks"
    assert Stuff.get("b") == "Jerks"
  end

  test "Can create sequence of stubs" do
    allow(Stuff.get(:_)).to_return seq([1,2,3])

    assert Stuff.get("a") == 1
    assert Stuff.get("b") == 2
    assert Stuff.get("c") == 3
    assert Stuff.get("d") == 3
  end

  test "Can create loop of stubs" do
    allow(Stuff.get(:_)).to_return loop([1,2,3])

    assert Stuff.get("a") == 1
    assert Stuff.get("b") == 2
    assert Stuff.get("c") == 3
    assert Stuff.get("d") == 1
  end

  test "assert_called validate call to mock was made" do
    allow(Stuff.get(:_)).to_return "Testing"

    Stuff.get("a")
    Stuff.get("a")

    assert_called Stuff.get("a")
  end

  test "validator once" do
    allow(Stuff.get(:_)).to_return "Testing"

    Stuff.get("a")
    Stuff.get("a")

    refute_called Stuff.get("a"), once()
  end

  test "validator times" do
    allow(Stuff.get(:_)).to_return "Testing"

    Stuff.get("a")
    Stuff.get("a")

    assert_called Stuff.get("a"), times(2)
  end

  test "refute negative validator times" do
    allow(Stuff.get(:_)).to_return "Testing"

    Stuff.get("a")

    refute_called Stuff.get("a"), times(2)
  end

end
