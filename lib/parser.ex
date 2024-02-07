defmodule Parser do
  def parse_string(string) do
    regex = ~r/%R\s+(\S+)\s+\((.*?)\)\s+\((.*?)\)/
    regex2 = ~r/%R\s+(\S+)\s+\(((?:[^()]|\((?>[^()]+|\g<0>)*\))*)\)/
    regex3 = ~r/%R\s+(\S+)\s+\(((?:[^()]|\((?>[^()]+|\g<0>)*\))*)\)\s+\((.*)\)\)\)/

    case Regex.scan(regex3, string) do
      [[_, part1, part2, part3]] -> {:ok, [part1, part2, part3]}
      _ -> {:error, "Invalid format"}
    end
  end
end

# Test
string = "((%R plus-time-one ((I-ALLOCMONO +) (I-ALLOCMONO +)) ((I-LOOKUP time) (I-SUPPLY (%RREF 1) (%DREF 1) 1) (I-SUPPLY (%SRC 1) (%DREF 1) 2) (I-REACT (%DREF 1)) (I-CONSUME (%DREF 1) 1) (I-SUPPLY (%RREF 5) (%DREF 2) 1) (I-SUPPLY 1 (%DREF 2) 2) (I-REACT (%DREF 2)) (I-CONSUME (%DREF 2) 1) (I-SINK (%RREF 9) 1))))"
case Parser.parse_string(string) do
  {:ok, [part1, part2, part3]} ->
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
    IO.puts("Part 3: #{String.split(part3, " ")}")
  {:ok, [part1, part2]} ->
      IO.puts("Part 1: #{part1}")
      IO.puts("Part 2: #{part2}")
  {:error, message} -> IO.puts(message)
end
