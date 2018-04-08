defmodule Geohash.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geohash,
      version: "1.1.0",
      elixir: "~> 1.3",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp description do
    """
    Geohash encode/decode implementation for Elixir
    """
  end

  defp package do
    [
      maintainers: ["Pablo Mouzo"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/polmuz/elixir-geohash"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excheck, "~> 0.5", only: :test},
      {:triq, github: "triqng/triq", only: :test}
    ]
  end
end
