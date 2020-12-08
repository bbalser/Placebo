defmodule Placebo.MeckTest do
  use ExUnit.Case

  test "callers can handle dead pid" do
    {:ok, pid} = Agent.start_link(fn -> 0 end)
    Agent.stop(pid, :normal)
    refute Process.alive?(pid)

    assert [pid] == Placebo.Meck.callers(pid)
  end
end
