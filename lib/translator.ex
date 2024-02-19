defmodule Translator do
  # Deployment-time instructions
  # Handle I-ALLOCMONO
  def translate_operation(["I-ALLOCMONO", reactor]) do
    "allocate reactor #{reactor}"
  end


  # Handle I-LOOKUP
  def translate_operation(["I-LOOKUP", "time"]) do
    "current_time = System.os_time()"
  end

  # Handle I-SUPPLY

  def translate_operation(["I-SUPPLY", [from, value], [to, destination], index])
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    translate_operation_impl(from, value, to, destination, index)
  end

  def translate_operation(["I-SUPPLY", value, [to, destination], index])
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    translate_operation_impl(value, to, destination, index)
  end

  def translate_operation_impl(from, value, to, destination, index) do
    "supply #{from} #{value} to #{to} #{destination} (index: #{index})"
  end

  def translate_operation_impl(value, to, destination, index) do
    "supply #{value} to #{to} #{destination} (index: #{index})"
  end

  ## translate ##

  def translate_representation(representation) do
    representation
    |> Enum.map(&translate_operation/1)
  end
end

# Example low-level representation
representation = [
  ["I-ALLOCMONO", '+'],
  ["I-LOOKUP", "time"],
  ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
  ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
  ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2]
  # Add more operations...
]

# Translate representation to Elixir code
elixir_code = Translator.translate_representation(representation)

# Output the generated Elixir code
Enum.each(elixir_code, &IO.puts/1)
