defmodule BoxScanner do
  def has_tuple?(id) do
    elements(id)
    |> to_dict
    |> group_by_char
    |> Map.has_key?(2)
  end

  def has_triples?(id) do
    elements(id)
    |> to_dict
    |> group_by_char
    |> Map.has_key?(3)
  end

  def elements(id), do: String.split(id, "", trim: true)

  def to_dict(elems),
    do: Enum.reduce(elems, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

  def group_by_char(elems),
    do: Enum.group_by(elems, fn {_, count} -> count end, fn {char, _} -> char end)
end

input =
  File.read!("in/day-2")
  |> String.split("\n", trim: true)

{tuples, triplets} =
  Enum.reduce(input, {0, 0}, fn x, {tuples, triplets} ->
    {
      if(BoxScanner.has_tuple?(x), do: tuples + 1, else: tuples),
      if(BoxScanner.has_triples?(x), do: triplets + 1, else: triplets)
    }
  end)

IO.inspect(tuples * triplets, label: "Step 1")

{{a, b}, _} =
  for x <- input, y <- input do
    {x, y}
  end
  |> Enum.reject(fn {x, y} -> x == y end)
  |> Enum.map(fn {x, y} = pair -> {pair, String.jaro_distance(x, y)} end)
  |> Enum.sort_by(fn {_, dist} -> dist end)
  |> List.last()

String.myers_difference(a, b)
|> Enum.reduce("", fn
  {:eq, x}, acc -> acc <> x
  _, acc -> acc
end)
|> IO.inspect(label: "Step 2")
