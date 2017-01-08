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

- Find neighbors

```Elixir
Geohash.neighbors("abx1")
# %{"n" => "abx4",
#   "s" => "abx0",
#   "e" => "abx3",
#   "w" => "abwc",
#   "ne" => "abx6",
#   "se" => "abx2",
#   "nw" => "abwf",
#   "sw" => "abwb"}
```

- Find adjacent

```Elixir
Geohash.adjacent("abx1","n")
# "abx4"
```

## Installation

  1. Add geohash to your list of dependencies in `mix.exs`:

        def deps do
          [{:geohash, "~> 1.0"}]
        end

  2. Ensure geohash is started before your application:

        def application do
          [applications: [:geohash]]
        end
