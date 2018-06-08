defmodule Mockit.Mock do
  defstruct [:module, :function, :args, :opts, :action]
end

defmodule Mockit.Expectation do
  defstruct [:module, :function, :args]
end
