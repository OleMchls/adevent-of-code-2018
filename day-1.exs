defmodule Feqs do
  def tune(current, changes), do: tune(current, changes, [0], changes)

  def tune(current, [], old, all_changes), do: tune(current, all_changes, old, all_changes)

  def tune(current, [chg | changes], old, all_changes) do
    new = current + chg

    if new in old,
      do: new,
      else: tune(new, changes, [new | old], all_changes)
  end
end

File.read!("in/day-1")
|> String.split("\n", trim: true)
|> Enum.map(&String.to_integer/1)
|> Enum.sum()
|> IO.inspect(label: "Step 1")

# Step 2
chgs =
  File.read!("in/day-1")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

Feqs.tune(0, chgs ++ chgs)
|> IO.inspect(label: "Step 2")
