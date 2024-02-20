defmodule Translator do
  # Handle all known instructions

  # Handle I-ALLOCMONO
  def translate_operation(["I-ALLOCMONO", reactor]) do
    "allocate reactor #{reactor}"
  end

  # Handle I-LOOKUP
  def translate_operation(["I-LOOKUP", "time"]) do
    "current_time = System.os_time()"
  end

  # Handle I-SUPPLY
  # supply memory location
  def translate_operation(["I-SUPPLY", [from, value], [to, destination], index])
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    translate_i_supply(from, value, to, destination, index)
  end

  # supply constant
  def translate_operation(["I-SUPPLY", value, [to, destination], index])
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    translate_i_supply(value, to, destination, index)
  end

  # Handle I-REACT
  def translate_operation(["I-REACT", [from, value]])
      when is_integer(value) do
    translate_i_react(from, value)
  end

  # Handle I-CONSUME
  def translate_operation(["I-CONSUME", [from, value], index])
      when is_integer(value) and is_integer(index) do
    translate_i_consume(from, value, index)
  end

  # Handle I-SINK
  def translate_operation(["I-SINK", [from, value], index])
      when is_integer(value) and is_integer(index) do
    translate_i_sink(from, value, index)
  end

  # Translator functions:

  def translate_i_supply(value, to, destination, index) do
    "supply #{value} to #{to} #{destination} (index: #{index})"
  end

  def translate_i_supply(from, value, to, destination, index) do
    "supply #{from} #{value} to #{to} #{destination} (index: #{index})"
  end

  def translate_i_react(from, value) do
    "react #{from} #{value}"
  end

  def translate_i_consume(from, value, index) do
    "conusme #{from} #{value} (index: #{index})"
  end

  def translate_i_sink(from, value, index) do
    "sink #{from} #{value} (index: #{index})"
  end

  ## translate the representation ##

  def translate_representation(representation) do
    representation
    |> Enum.map(&translate_operation/1)
  end
end

# Low-level representation

representation = [
  "plus-time-one",
  [
    ["I-ALLOCMONO", "+"],
    ["I-ALLOCMONO", "+"]
  ],
  [
    ["I-LOOKUP", "time"],
    ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
    ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
    ["I-REACT", ["%DREF", 1]],
    ["I-CONSUME", ["%DREF", 1], 1],
    ["I-SUPPLY", ["%RREF", 5], ["%DREF", 2], 1],
    ["I-SUPPLY", 1, ["%DREF", 2], 2],
    ["I-REACT", ["%DREF", 2]],
    ["I-CONSUME", ["%DREF", 2], 1],
    ["I-SINK", ["%RREF", 9], 1]
  ]
]

# Match the tree parts of the representation:
# reaktor name, deployment-time instructions, react-time instructions
[reactor_name, dti, rti] = representation

# Translate representation to Elixir code
elixir_code =
  Enum.concat(Translator.translate_representation(dti), Translator.translate_representation(rti))

# Output the generated Elixir code
Enum.each(elixir_code, &IO.puts/1)
