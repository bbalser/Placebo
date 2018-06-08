defmodule Mockit.Application do
  use Application

  def start(_type, _args) do
    children = [
      Mockit.Server
    ]

    Supervisor.start_link(children, name: Mockit.Supervisor, strategy: :one_for_one)
  end

end
