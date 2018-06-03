defmodule Mockit.Mock do
  defstruct [:module, :function, :args, :opts, :action]
end

defmodule Mockit.Excpetation do
  defstruct [:module, :function, :args]
end
