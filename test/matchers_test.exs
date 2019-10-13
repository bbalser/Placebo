defmodule Placebo.MatchersTest do
  use ExUnit.Case
  use Placebo

  test "is_true/is_false" do
    allow Regex.regex?(any()), return: "Something Else"
    allow Regex.regex?(is_true()), return: "True"
    allow Regex.regex?(is_false()), return: "False"

    assert Regex.regex?(true) == "True"
    assert Regex.regex?(false) == "False"
  end

  test "starts_with/ends_with/string_contains" do
    allow Regex.regex?(any()), return: "Error"
    allow Regex.regex?(starts_with("Holy")), return: "Cow"
    allow Regex.regex?(ends_with("Cow")), return: "Holy"
    allow Regex.regex?(contains_string("in the")), return: "middle"

    assert Regex.regex?("Holy Molly") == "Cow"
    assert Regex.regex?("Blue Cow") == "Holy"
    assert Regex.regex?("man in the middle") == "middle"
    assert Regex.regex?("Holly") == "Error"
  end

  test "is" do
    allow Regex.regex?(any()), return: "Odd"
    allow Regex.regex?(is(fn arg -> rem(arg, 2) == 0 end)), return: "Even"

    assert Regex.regex?(4) == "Even"
    assert Regex.regex?(3) == "Odd"
  end

  test "any() allows any argument" do
    allow Regex.regex?(any()), return: :ANY
    assert Regex.regex?(:atom) == :ANY
    assert Regex.regex?("string") == :ANY
    assert Regex.regex?(1) == :ANY
    assert Regex.regex?({:tuple, 0}) == :ANY
    assert Regex.regex?(["a", "list"]) == :ANY
    assert Regex.regex?(%{map: "value"}) == :ANY
  end

  test "term() allows any argument" do
    allow Regex.regex?(term()), return: :TERM
    assert Regex.regex?(:atom) == :TERM
    assert Regex.regex?("string") == :TERM
    assert Regex.regex?(1) == :TERM
    assert Regex.regex?({:tuple, 0}) == :TERM
    assert Regex.regex?(["a", "list"]) == :TERM
    assert Regex.regex?(%{map: "value"}) == :TERM
  end

  test "matching" do
    allow URI.decode(any()), return: :no_match
    allow URI.decode(matching(~r/bar/)), return: :bar
    allow URI.decode(matching(~r/baz/)), return: :baz

    assert URI.decode("foobar") == :bar
    assert URI.decode("barndoor") == :bar
    assert URI.decode("foobaz") == :baz
    assert URI.decode("other") == :no_match
  end
end
