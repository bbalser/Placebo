defmodule Mockit.MatchersTest do
  use ExUnit.Case
  use Mockit

  test "is_true/is_false" do
    allow(Mockit.Dummy.get(is_true())).to return "True"
    allow(Mockit.Dummy.get(is_false())).to return "False"
    allow(Mockit.Dummy.get(any())).to return "Something Else"

    assert Mockit.Dummy.get(true) == "True"
    assert Mockit.Dummy.get(false) == "False"
  end

  test "starts_with/ends_with/string_contains" do
    allow(Mockit.Dummy.get(starts_with("Holy"))).to return "Cow"
    allow(Mockit.Dummy.get(ends_with("Cow"))).to return "Holy"
    allow(Mockit.Dummy.get(contains_string("middle"))).to return "Middle"
    allow(Mockit.Dummy.get(any())).to return "Error"

    assert Mockit.Dummy.get("Holy Molly") == "Cow"
    assert Mockit.Dummy.get("Blue Cow") == "Holy"
    assert Mockit.Dummy.get("man in the middle") == "Middle"
    assert Mockit.Dummy.get("Holly") == "Error"
  end

  test "is" do
    allow(Mockit.Dummy.get(is(fn arg -> rem(arg,2) == 0 end))).to return "Even"
    allow(Mockit.Dummy.get(any())).to return "Odd"

    assert Mockit.Dummy.get(4) == "Even"
    assert Mockit.Dummy.get(3) == "Odd"
  end

end
