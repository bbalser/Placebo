defmodule Placebo.MixProject do
  use Mix.Project

  def project do
    [
      app: :placebo,
      version: "2.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Placebo"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Placebo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:meck, "~> 0.9"},
      {:mix_test_watch, "~> 0.6.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:stream_data, "~> 0.4", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      maintainers: ["Brian Balser", "Johnson Denen"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bbalser/Placebo"}
    ]
  end

  defp description do
    "A mocking library for ExUnit inspired by RSpec and based on meck."
  end
end
