defmodule Aegis.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :aegis,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.4", optional: true},
    ]
  end

  defp elixirc_paths(:test),     do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
