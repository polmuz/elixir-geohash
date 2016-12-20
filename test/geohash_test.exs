defmodule GeohashTest do
  use ExUnit.Case
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
    assert Geohash.adjacent("ww8p1r4t8","e") == "ww8p1r4t9"
  end
end
