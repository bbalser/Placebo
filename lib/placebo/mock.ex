defmodule Placebo.Mock do
  defstruct [:module, :function, :args, :opts, :action]
end

defmodule Placebo.Expectation do
  defstruct [:module, :function, :args]
end
