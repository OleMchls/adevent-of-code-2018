defmodule Fabric do
  import String, only: [to_integer: 1]

  defmodule Claim do
    defstruct [:id, :left, :top, :height, :width, :coordinates]

    def overlap?(%Claim{} = claim1, %Claim{} = claim2) do
      Enum.any?(claim1.coordinates, fn x -> x in claim2.coordinates end)
    end
  end

  def parse_claim(claim) do
    command = ~r'#(\d+) @ (\d+),(\d+): (\d+)x(\d+)'
    [_, id, left, top, height, width] = Regex.run(command, claim)

    %Claim{
      id: id,
      left: to_integer(left),
      top: to_integer(top),
      height: to_integer(height),
      width: to_integer(width)
    }
    |> populate_coordinates()
  end

  def find_non_overlapping([claim | []]), do: claim

  def find_non_overlapping([claim | claims]) do
    IO.inspect(length(claims), label: "remaining claims")
    cleared_claims = Enum.reject(claims, &Claim.overlap?(&1, claim))
    find_non_overlapping(cleared_claims ++ [claim])
  end

  defp populate_coordinates(%Claim{left: left, top: top, height: h, width: w} = claim) do
    coordinates =
      for x <- 1..h, y <- 1..w do
        {left + x, top + y}
      end

    %Claim{claim | coordinates: coordinates}
  end
end

input =
  File.read!("in/day-3")
  |> String.split("\n", trim: true)

Enum.map(input, &Fabric.parse_claim/1)
|> Enum.map(& &1.coordinates)
|> List.flatten()
|> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
|> Enum.filter(fn {_, count} -> count > 1 end)
|> length
|> IO.inspect(label: "Step 1")

claims = Enum.map(input, &Fabric.parse_claim/1)

Task.async_stream(
  claims,
  fn c1 -> {c1, Enum.filter(claims, fn c2 -> Fabric.Claim.overlap?(c1, c2) end)} end,
  timeout: 100_000_000
)
|> IO.inspect(label: "results")
|> Stream.reject(fn {_, {_, overlaps}} -> length(overlaps) > 1 end)
|> IO.inspect(label: "done")
|> Enum.to_list()
|> IO.inspect(label: "Step 2")
