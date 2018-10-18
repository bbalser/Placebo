defmodule Placebo.MatchersTest do
  use ExUnit.Case
  use Placebo

  test "is_true/is_false" do
    allow Placebo.Dummy.get(is_true()), return: "True"
    allow Placebo.Dummy.get(is_false()), return: "False"
    allow Placebo.Dummy.get(any()), return: "Something Else"

    assert Placebo.Dummy.get(true) == "True"
    assert Placebo.Dummy.get(false) == "False"
  end

  test "starts_with/ends_with/string_contains" do
    allow Placebo.Dummy.get(starts_with("Holy")), return: "Cow"
    allow Placebo.Dummy.get(ends_with("Cow")), return: "Holy"
    allow Placebo.Dummy.get(contains_string("middle")), return: "Middle"
    allow Placebo.Dummy.get(any()), return: "Error"

    assert Placebo.Dummy.get("Holy Molly") == "Cow"
    assert Placebo.Dummy.get("Blue Cow") == "Holy"
    assert Placebo.Dummy.get("man in the middle") == "Middle"
    assert Placebo.Dummy.get("Holly") == "Error"
  end

  test "is" do
    allow Placebo.Dummy.get(is(fn arg -> rem(arg,2) == 0 end)), return: "Even"
    allow Placebo.Dummy.get(any()), return: "Odd"

    assert Placebo.Dummy.get(4) == "Even"
    assert Placebo.Dummy.get(3) == "Odd"
  end

  test "any() allows any argument" do
    allow Placebo.Dummy.get(any()), return: :ANY
    assert Placebo.Dummy.get(:atom) == :ANY
    assert Placebo.Dummy.get("string") == :ANY
    assert Placebo.Dummy.get(1) == :ANY
    assert Placebo.Dummy.get({:tuple, 0}) == :ANY
    assert Placebo.Dummy.get(["a", "list"]) == :ANY
    assert Placebo.Dummy.get(%{map: "value"}) == :ANY
  end

  test "term() allows any argument" do
    allow Placebo.Dummy.get(term()), return: :TERM
    assert Placebo.Dummy.get(:atom) == :TERM
    assert Placebo.Dummy.get("string") == :TERM
    assert Placebo.Dummy.get(1) == :TERM
    assert Placebo.Dummy.get({:tuple, 0}) == :TERM
    assert Placebo.Dummy.get(["a", "list"]) == :TERM
    assert Placebo.Dummy.get(%{map: "value"}) == :TERM
  end

end
