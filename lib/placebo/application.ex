defmodule Placebo.Application do
  use Application

  def start(_type, _args) do
    children = [
      Placebo.Server
    ]

    Supervisor.start_link(children, name: Placebo.Supervisor, strategy: :one_for_one)
  end
end
