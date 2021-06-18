defmodule Geohash.Helpers do
  @moduledoc ~S"""
  Helpers for preparing static geohash data(gebase32, neighbor map) at compile time,
  aiming at increasing performance.
  """

  def prepare_directions(directions) when is_map(directions) do
    directions
    |> Enum.reduce(%{}, fn {d, {t1, t2}}, acc ->
      Map.put(acc, d, {Enum.into(Enum.with_index(t1), %{}), Enum.into(Enum.with_index(t2), %{})})
    end)
  end

  def prepare_indexed(geobase32) when is_list(geobase32) do
    geobase32
    |> Enum.with_index()
    |> Enum.into(%{})
  end
end
