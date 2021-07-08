# Geohash

[![Build Status](https://travis-ci.org/polmuz/elixir-geohash.svg?branch=master)](https://travis-ci.org/polmuz/elixir-geohash)
[![Module Version](https://img.shields.io/hexpm/v/geohash.svg)](https://hex.pm/packages/geohash)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/geohash/)
[![Total Download](https://img.shields.io/hexpm/dt/geohash.svg)](https://hex.pm/packages/geohash)
[![License](https://img.shields.io/hexpm/l/geohash.svg)](https://github.com/polmuz/elixir-geohash/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/polmuz/elixir-geohash.svg)](https://github.com/polmuz/elixir-geohash/commits/master)

[Geohash](https://en.wikipedia.org/wiki/Geohash) encoder/decoder implementation for Elixir.

## Installation

Add `:geohash` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geohash, "~> 1.0"}
  ]
end
```

Ensure `:geohash` is started before your application:

```elixir
def application do
  [
    applications: [:geohash]
  ]
end
```

## Usage

Encode coordinates with `Geohash.encode(lat, lon, precision \\ 11)`:

```elixir
Geohash.encode(42.6, -5.6, 5)
# "ezs42"
```

Decode coordinates with `Geohash.decode(geohash)`:

```elixir
Geohash.decode("ezs42")
# {42.605, -5.603}
```

Find neighbors:

```elixir
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

Find adjacent:

```elixir
Geohash.adjacent("abx1","n")
# "abx4"
```

Get bounds:

```elixir
Geohash.bounds("u4pruydqqv")
# %{min_lon: 10.407432317733765, min_lat: 57.649109959602356, max_lon: 10.407443046569824, max_lat: 57.649115324020386}
```

## Copyright and License

Copyright (c) 2015 Pablo Mouzo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
