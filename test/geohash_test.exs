defmodule GeohashTest do
  use ExUnit.Case
  use ExCheck
  doctest Geohash

  test "Geohash.encode" do
    assert Geohash.encode(57.64911, 10.40744) == "u4pruydqqvj"
    assert Geohash.encode(50.958087, 6.9204459) == "u1hcvkxk65f"
    assert Geohash.encode(39.51, -76.24, 10) == "dr1bc0edrj"
    assert Geohash.encode(42.6, -5.6, 5) == "ezs42"
    assert Geohash.encode(0, 0) == "s0000000000"
    assert Geohash.encode(0, 0, 2) == "s0"
    assert Geohash.encode(57.648, 10.410, 6) == "u4pruy"
    assert Geohash.encode(-25.38262, -49.26561, 8) == "6gkzwgjz"
  end

  test "Geohash.encode matches elasticsearch geohash example" do
    assert Geohash.encode(51.501568, -0.141257, 1)  == "g"
    assert Geohash.encode(51.501568, -0.141257, 2)  == "gc"
    assert Geohash.encode(51.501568, -0.141257, 3)  == "gcp"
    assert Geohash.encode(51.501568, -0.141257, 4)  == "gcpu"
    assert Geohash.encode(51.501568, -0.141257, 5)  == "gcpuu"
    assert Geohash.encode(51.501568, -0.141257, 6)  == "gcpuuz"
    assert Geohash.encode(51.501568, -0.141257, 7)  == "gcpuuz9"
    assert Geohash.encode(51.501568, -0.141257, 8)  == "gcpuuz94"
    assert Geohash.encode(51.501568, -0.141257, 9)  == "gcpuuz94k"
    assert Geohash.encode(51.501568, -0.141257, 10) == "gcpuuz94kk"
    assert Geohash.encode(51.501568, -0.141257, 11) == "gcpuuz94kkp"
    assert Geohash.encode(51.501568, -0.141257, 12) == "gcpuuz94kkp5"
  end

  test "Geohash.decode_to_bits" do
    assert Geohash.decode_to_bits("ezs42") == <<0b0110111111110000010000010::25>>
  end

  test "Geohash.decode" do
    assert Geohash.decode("ww8p1r4t8") == {37.832386, 112.558386}
    assert Geohash.decode("ezs42") == {42.605, -5.603}
    assert Geohash.decode("u4pruy") == {57.648, 10.410}
    assert Geohash.decode('6gkzwgjz') == {-25.38262, -49.26561}
  end

  test "Geohash.neighbors" do
    assert Geohash.neighbors("6gkzwgjz") == %{"n" => "6gkzwgmb",
                                              "s" => "6gkzwgjy",
                                              "e" => "6gkzwgnp",
                                              "w" => "6gkzwgjx",
                                              "ne"=> "6gkzwgq0",
                                              "se"=> "6gkzwgnn",
                                              "nw"=> "6gkzwgm8",
                                              "sw"=> "6gkzwgjw"}
    assert Geohash.adjacent("ww8p1r4t8", "e") == "ww8p1r4t9"
  end

  @geobase32 '0123456789bcdefghjkmnpqrstuvwxyz'

  defp geocodes_domain, do: resize(12, non_empty(list(elements(@geobase32))))

  @tag iterations: 10000
  property "decode is reversible" do
    for_all geohash in geocodes_domain() do
      geohash = to_string(geohash)
      precision = String.length(geohash)
      {lat, lng} = Geohash.decode(geohash)
      new_geohash = Geohash.encode(lat, lng, precision)
      geohash == new_geohash
    end
  end

  @tag iterations: 10000
  property "neighbors is reversible" do
    for_all geohash in geocodes_domain() do
      geohash = to_string(geohash)

      for {direction, opposite} <- [{"n", "s"}, {"e", "w"}, {"s", "n"}, {"w", "e"}] do
        adj = Geohash.adjacent(geohash, direction)
        original = Geohash.adjacent(adj, opposite)
        assert(
          geohash === original,
          "Inverse operation didn't work \"#{geohash} -> #{adj} -> #{original}\""
        )
      end |> Enum.all?
    end
  end

  def coords_domain do
    domain(
      :coord_lat,
      fn (self, _size) ->
        lat = 90.0 - :rand.uniform * 90.0 * 2
        lng = 180.0 - :rand.uniform * 180.0 * 2
        {self, {lat, lng}}
      end,
      fn
        (_self, _value) -> {0, 0}
      end
    )
  end

  # TODO: Check if error margins are correct, if so, fix error
  #       in rounding code
  # Error margins taken from Wikipedia's Geohash page
  # @error_margin %{
  #   1 => {23, 23},
  #   2 => {2.8, 5.6},
  #   3 => {0.70, 0.7},
  #   4 => {0.087, 0.18},
  #   5 => {0.022, 0.022},
  #   6 => {0.0027, 0.0055},
  #   7 => {0.00068, 0.00068},
  #   8 => {0.000085, 0.00017},
  # }
  #
  # property "errors are below margin after encode/decode" do
  #   for_all {lat, lng} in coords() do
  #     precision = :rand.uniform(8)
  #     geohash = Geohash.encode(lat, lng, precision)
  #     {new_lat, new_lng} = Geohash.decode(geohash)
  #     new_geohash = Geohash.encode(new_lat, new_lng, precision)
  #     {lat_error, lng_error} = @error_margin[precision]
  #     ok? = (abs(new_lat - lat) <= lat_error and abs(lng - new_lng) <= lng_error)
  #     unless ok? do
  #       IO.inspect {"coords", {lat, lng}}
  #       IO.inspect {"precision", precision}
  #       IO.inspect {"new coords", {new_lat, new_lng}}
  #       IO.inspect {"error margin", {lat_error, lng_error}}
  #       IO.inspect {"real error", {new_lat - lat, lng - new_lng}}
  #       IO.inspect {geohash, new_geohash}
  #     end
  #     ok?
  #   end
  # end

  @tag iterations: 10000
  property "encode -> decode -> encode is the same geohash" do
    for_all {lat, lng} in coords_domain() do
      precision = :rand.uniform(8)
      geohash = Geohash.encode(lat, lng, precision)
      {new_lat, new_lng} = Geohash.decode(geohash)
      new_geohash = Geohash.encode(new_lat, new_lng, precision)
      assert geohash == new_geohash
    end
  end
end
