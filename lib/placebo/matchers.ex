defmodule Placebo.Matchers do
  import Placebo.Macros

  def any, do: :_
  defdelegate term, to: __MODULE__, as: :any

  matcher :is_true, do: arg == true
  matcher :is_false, do: arg == false

  matcher :starts_with, do: String.starts_with?(arg, input)
  matcher :ends_with, do: String.ends_with?(arg, input)
  matcher :contains_string, do: String.contains?(arg, input)

  matcher :eq, do: arg == input
  matcher :gt, do: arg > input
  matcher :gte, do: arg >= input
  matcher :lt, do: arg < input
  matcher :lte, do: arg <= input
  matcher :ne, do: arg != input

  matcher :contains_member, do: Enum.member?(arg, input)
  matcher :is_empty, do: Enum.empty?(arg)

  matcher :is_alive, do: Process.alive?(arg)
  matcher :is_dead, do: not Process.alive?(arg)

  def is(function) when is_function(function) do
    :meck.is(function)
  end
end
