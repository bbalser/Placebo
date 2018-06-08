defmodule Placebo.MatchersTest do
  use ExUnit.Case
  use Placebo

  test "is_true/is_false" do
    allow(Placebo.Dummy.get(is_true())).to return "True"
    allow(Placebo.Dummy.get(is_false())).to return "False"
    allow(Placebo.Dummy.get(any())).to return "Something Else"

    assert Placebo.Dummy.get(true) == "True"
    assert Placebo.Dummy.get(false) == "False"
  end

  test "starts_with/ends_with/string_contains" do
    allow(Placebo.Dummy.get(starts_with("Holy"))).to return "Cow"
    allow(Placebo.Dummy.get(ends_with("Cow"))).to return "Holy"
    allow(Placebo.Dummy.get(contains_string("middle"))).to return "Middle"
    allow(Placebo.Dummy.get(any())).to return "Error"

    assert Placebo.Dummy.get("Holy Molly") == "Cow"
    assert Placebo.Dummy.get("Blue Cow") == "Holy"
    assert Placebo.Dummy.get("man in the middle") == "Middle"
    assert Placebo.Dummy.get("Holly") == "Error"
  end

  test "is" do
    allow(Placebo.Dummy.get(is(fn arg -> rem(arg,2) == 0 end))).to return "Even"
    allow(Placebo.Dummy.get(any())).to return "Odd"

    assert Placebo.Dummy.get(4) == "Even"
    assert Placebo.Dummy.get(3) == "Odd"
  end

end
