defmodule Geohash.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geohash,
      version: "1.1.0",
      elixir: "~> 1.6",
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

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:stream_data, "~> 0.4", only: [:test, :dev]}
    ]
  end
end
