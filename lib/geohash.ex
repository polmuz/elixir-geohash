defmodule Geohash do
  @moduledoc ~S"""
  Geohash encode/decode and helper functions

  ## Usage

  - Encode coordinates with `Geohash.encode(lat, lon, precision \\ 11)`

  ```
  Geohash.encode(42.6, -5.6, 5)
  # "ezs42"
  ```

  - Decode coordinates with `Geohash.decode(geohash)`

  ```
  Geohash.decode("ezs42")
  # {42.605, -5.603}
  ```

  - Find neighbors with `Geohash.neighbors(geohash)`

  ```
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

  - Find adjacent with `Geohash.adjacent(geohash, direction)`

  ```
  Geohash.adjacent("abx1", "n")
  # "abx4"
  ```
  """

  @geobase32 '0123456789bcdefghjkmnpqrstuvwxyz'

  @doc ~S"""
  Encodes given coordinates to a geohash of length `precision`

  ## Examples

  ```
  iex> Geohash.encode(42.6, -5.6, 5)
  "ezs42"

  ```
  """
  def encode(lat, lon, precision \\ 11) do
    bits = encode_to_bits(lat, lon, precision * 5)
    to_geobase32(bits)
  end

  @doc ~S"""
  Encodes given coordinates to a bitstring of length `bits_length`

  ## Examples

  ```
  iex> Geohash.encode_to_bits(42.6, -5.6, 25)
  <<0b0110111111110000010000010::25>>

  ```
  """
  def encode_to_bits(lat, lon, bits_length) do
    starting_position = bits_length - 1
    lat_bits = lat_to_bits(lat, starting_position - 1) # odd bits
    lon_bits = lon_to_bits(lon, starting_position) # even bits
    geo_bits = lat_bits + lon_bits
    <<geo_bits::size(bits_length)>>
  end

  defp to_geobase32(bits) do
    chars = for << c::5 <- bits >>, do: Enum.fetch!(@geobase32, c)
    chars |> to_string
  end

  defp lon_to_bits(lon, position) do
    geo_to_bits(lon, position, {-180.0, 180.0})
  end

  defp lat_to_bits(lat, position) do
    geo_to_bits(lat, position, {-90.0, 90.0})
  end

  defp geo_to_bits(_, position, _) when position < 0 do
    0
  end

  # Decodes given lat or lon creating the bits using 2^x to
  # positionate the bit instead of building a bitstring.

  # It moves by 2 to already set the bits on odd or even positions.

  defp geo_to_bits(n, position, {gmin, gmax}) do
    mid = (gmin + gmax) / 2

    if n >= mid do
        round(:math.pow(2, position)) + geo_to_bits(n, position - 2, {mid, gmax})
    else
        geo_to_bits(n, position - 2, {gmin, mid})
    end
  end

  #--------------------------

  @doc ~S"""
  Decodes given geohash to a coordinate pair

  ## Examples

  ```
  iex> {lat, lng} = Geohash.decode("ezs42")
  {42.605, -5.603}

  ```
  """
  def decode(geohash) do
    geohash
    |> decode_to_bits
    |> bits_to_coordinates_pair
  end

  @doc ~S"""
  Decodes given geohash to a bitstring

  ## Examples

  ```
  iex> Geohash.decode_to_bits("ezs42")
  <<0b0110111111110000010000010::25>>

  ```
  """
  def decode_to_bits(geohash) do
    geohash
    |> to_char_list
    |> Enum.map(&from_geobase32/1)
    |> Enum.reduce(<<>>, fn(c, acc) -> << acc::bitstring, c::bitstring >> end)
  end

  defp bits_to_coordinates_pair(bits) do
    bitslist = for << bit::1 <- bits >>, do: bit
    lat = bitslist
    |> filter_odd
    |> Enum.reduce(fn (bit, acc) -> <<acc::bitstring, bit::bitstring>> end)
    |> bits_to_coordinate({-90.0, 90.0})

    lon = bitslist
    |> filter_even
    |> Enum.reduce(fn (bit, acc) -> <<acc::bitstring, bit::bitstring>> end)
    |> bits_to_coordinate({-180.0, 180.0})

    {lat, lon}
  end

  @neighbor %{
    "n" => {'p0r21436x8zb9dcf5h7kjnmqesgutwvy', 'bc01fg45238967deuvhjyznpkmstqrwx'},
    "s" => {'14365h7k9dcfesgujnmqp0r2twvyx8zb', '238967debc01fg45kmstqrwxuvhjyznp'},
    "e" => {'bc01fg45238967deuvhjyznpkmstqrwx', 'p0r21436x8zb9dcf5h7kjnmqesgutwvy'},
    "w" => {'238967debc01fg45kmstqrwxuvhjyznp', '14365h7k9dcfesgujnmqp0r2twvyx8zb'},
  }
  @border %{
    "n" => {'prxz', 'bcfguvyz'},
    "s" => {'028b', '0145hjnp'},
    "e" => {'bcfguvyz', 'prxz'},
    "w" => {'0145hjnp', '028b'},
  }

  defp border_case(direction, type, tail) do
    @border[direction]
    |> elem(type)
    |> Enum.find_index(fn r -> r == tail end)
  end

  @doc ~S"""
  Calculate `adjacent/2` geohash in ordinal direction `["n","s","e","w"]`.
  Deals with boundary cases when adjacent is not of the same prefix.

  ## Examples

  ```
  iex> Geohash.adjacent("abx1","n")
  "abx4"

  ```
  """
  def adjacent(geohash, direction) when direction in ["n", "s", "w", "e"] do
    prefix_len = byte_size(geohash) - 1
    # parent will be a string of the prefix, last_ch will be an int of last char
    <<parent::binary-size(prefix_len), last_ch::size(8)>> = geohash
    type = rem(prefix_len + 1, 2)

    # check for edge-cases which don't share common prefix
    parent = if border_case(direction, type, last_ch) && prefix_len > 0 do
      adjacent(parent,direction)
    else
      parent
    end

    # append letter for direction to parent
    # look up index of last char use as position in base32
    pos = @neighbor[direction]
    |> elem(type)
    |> Enum.find_index(fn r -> r == last_ch end)

    q = Enum.slice(@geobase32, pos, 1)
    parent <> to_string(q)
  end

  @doc ~S"""
  Calculate adjacent hashes for the 8 touching `neighbors/1`

  ## Examples

  ```
  iex> Geohash.neighbors("abx1")
  %{"n" => "abx4",
    "s" => "abx0",
    "e" => "abx3",
    "w" => "abwc",
    "ne" => "abx6",
    "se" => "abx2",
    "nw" => "abwf",
    "sw" => "abwb"}

  ```
  """
  def neighbors(geohash) do
    n = adjacent(geohash,"n")
    s = adjacent(geohash,"s")
    %{"n" => n,
      "s" => s,
      "e" => adjacent(geohash,"e"),
      "w" => adjacent(geohash,"w"),
      "ne" => adjacent(n,"e"),
      "se" => adjacent(s,"e"),
      "nw" => adjacent(n,"w"),
      "sw" => adjacent(s,"w"),
    }
  end

  defp filter_even(bitslists) do
    bitslists |> filter_periodically(2, 0)
  end

  defp filter_odd(bitslists) do
    bitslists |> filter_periodically(2, 1)
  end

  defp filter_periodically(bitslist, period, offset) do
    bitslist
    |> Enum.with_index
    |> Enum.filter(fn {_, i} -> rem(i, period) == offset end)
    |> Enum.map(fn {bit, _} -> <<bit::1>> end)
  end

  defp bits_to_coordinate(<<>>, {min, max}) do
    mid = (min + max) / 2
    round_coordinate(mid, {min, max})
  end

  defp bits_to_coordinate(bits, {min, max}) do
    << bit::1, rest::bitstring >> = bits
    mid = (min + max) / 2
    if bit == 1 do
        bits_to_coordinate(rest, {mid, max})
    else
        bits_to_coordinate(rest, {min, mid})
    end
  end

  # Rounding criteria taken from:
  # https://github.com/chrisveness/latlon-geohash/blob/decb13b09a7f1e219a2ca86ff8432fb9e2774fc7/latlon-geohash.js#L117

  # See demo of that implementation here:
  # http://www.movable-type.co.uk/scripts/geohash.html
  defp round_coordinate(coord, {min, max}) do
    Float.round(coord, round(Float.floor(2 - :math.log10(max - min))))
  end

  defp from_geobase32(char) do
    @geobase32
    |> Enum.with_index
    |> Enum.filter_map(fn {x, _} -> x == char end, fn {_, i} -> <<i::5>> end)
    |> List.first
  end
end
