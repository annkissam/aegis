defmodule Aegis.MixProject do
  use Mix.Project

  @version "0.1.2"
  @url "https://github.com/annkissam/aegis"
  @maintainers [
    "Josh Adams",
    "Eric Sullivan",
  ]

  def project do
    [
      app: :aegis,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Lightweight, flexible resource authorization.",
      package: package(),
      source_url: @url,
      homepage_url: @url,
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env),
      aliases: aliases(),
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.3", optional: true},
      {:ex_doc, "~> 0.10", only: :dev},
    ]
  end

  def docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      name: :aegis,
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{github: @url},
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG.md"],
    ]
  end

  defp aliases do
    ["publish": ["hex.publish", &git_tag/1]]
  end

  defp git_tag(_args) do
    System.cmd "git", ["tag", "v" <> Mix.Project.config[:version]]
    System.cmd "git", ["push", "--tags"]
  end
end
