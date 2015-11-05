# Geohash

[![Build Status](https://travis-ci.org/polmuz/elixir-geohash.svg?branch=master)](https://travis-ci.org/polmuz/elixir-geohash)

Geohash encode/decode implementation for Elixir

## Examples

- Encode coordinates with `Geohash.encode(lat, lon, precision \\ 11)`

```Elixir
Geohash.encode(42.6, -5.6, 5)
# "ezs42"
```

- Decode coordinates with `Geohash.decode(geohash)`

```Elixir
Geohash.decode("ezs42")
# {42.605, -5.603}
```

## Installation

  1. Add geohash to your list of dependencies in `mix.exs`:

        def deps do
          [{:geohash, "~> 0.1.1"}]
        end

  2. Ensure geohash is started before your application:

        def application do
          [applications: [:geohash]]
        end
