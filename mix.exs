defmodule Geohash.Mixfile do
  use Mix.Project

  @source_url "https://github.com/polmuz/elixir-geohash"
  @version "1.2.2"

  def project do
    [
      app: :geohash,
      version: @version,
      elixir: "~> 1.6",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  defp package do
    [
      description: "Geohash encoder/decoder implementation for Elixir",
      maintainers: ["Pablo Mouzo"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  def application do
    [
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:stream_data, "~> 0.4", only: [:test, :dev]}
    ]
  end

  defp docs do
    [
      extras: [
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
