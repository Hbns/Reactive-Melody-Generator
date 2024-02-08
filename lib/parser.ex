defmodule Parser do
  def parse_string(string) do
    regex = ~r/%R\s+(\S+)\s+\(((?:[^()]|\((?>[^()]+|\g<0>)*\))*)\)\s+\((.*)\)\)\)/

    case Regex.scan(regex, string) do
      [[_, name, dti, rti]] -> {:ok, %{name: name, dti: extract(dti), rti: rti}}
      _ -> {:error, "Invalid format"}
    end
  end
  defp extract(string) do
    regex = ~r/[^)]*.*[^)]*/
    case Regex.scan(regex, string) do
      [[_, parts]] -> {:ok, parts}
      _ -> {:error, "Invalid string format for splitting"}
    end
  end
end

# Test
reactor_bytecode =
  "((%R plus-time-one ((I-ALLOCMONO +) (I-ALLOCMONO +)) ((I-LOOKUP time) (I-SUPPLY (%RREF 1) (%DREF 1) 1) (I-SUPPLY (%SRC 1) (%DREF 1) 2) (I-REACT (%DREF 1)) (I-CONSUME (%DREF 1) 1) (I-SUPPLY (%RREF 5) (%DREF 2) 1) (I-SUPPLY 1 (%DREF 2) 2) (I-REACT (%DREF 2)) (I-CONSUME (%DREF 2) 1) (I-SINK (%RREF 9) 1))))"

reactor = Parser.parse_string(reactor_bytecode)
IO.inspect(reactor)
