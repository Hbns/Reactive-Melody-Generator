defmodule Haai do
  # definitions

  # module attributes, can only be static.
  @native_reactor_table %{plus: fn a, b -> a + b end, minus: fn a, b -> a - b end}
  @source_and_sink_native_reactor_table %{plus: {2, 1}, minus: {2, 1}}
  # @signal_table %{time: fn -> Time.utc_now() end}
  @signal_table %{time: 33}

  def start(reactor_byte_code) do
    [name, number_of_sources, number_of_sinks, dti, rti] = reactor_byte_code
    rb = make_dtm_block(name, number_of_sources, dti, rti, number_of_sinks)
    # asumes dti are only allocmono for native reactors!
    nb = make_native_dtm_blocks(dti)
    # arguments are (dtm,rtm,rti)
    run_reaktor([rb | nb], [], rti)
  end

  def run_start do
    # test reactor:
    pto = [
      :plus_time_one,
      1,
      1,
      [
        ["I-ALLOCMONO", :plus],
        ["I-ALLOCMONO", :plus]
      ],
      [
        ["I-LOOKUP", :time],
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

    start(pto)
  end

  # make memory blocks
  defp make_native_dtm_blocks([], acc \\ []) do
    Enum.reverse(acc)
  end

  defp make_native_dtm_blocks([["I-ALLOCMONO", native] | rest], acc) do
    {sources, sinks} = Map.get(@source_and_sink_native_reactor_table, native)
    block = {native, List.duplicate(0, sources), [], [], List.duplicate(0, sinks)}
    make_native_dtm_blocks(rest, [block | acc])
  end

  defp make_dtm_block(name, number_of_sources, dti, rti, number_of_sinks) do
    {name, List.duplicate(0, number_of_sources), dti, rti, List.duplicate(0, number_of_sinks)}
  end

  # Run the reaktor
  defp run_reaktor(dtm, rtm, rti) do
    Memory.start_link(dtm, rtm)
    # execute each rti
    Enum.each(rti, fn instruction -> hrr(instruction) end)
  end

  # Help running the reactor = hrr

  defp hrr(["I-LOOKUP", signal]) do
    value = Map.get(@signal_table, signal)
    t = Time.utc_now()
    IO.puts("lookup")
  end

  defp hrr(["I-SUPPLY", [from, value], [to, destination], index])
       when is_integer(value) and is_integer(destination) and is_integer(index) do
        Memory.supply_from_location(from, value, to, destination, index)
    IO.puts("supply_from_location")
  end

  defp hrr(["I-SUPPLY", value, [to, destination], index])
  when is_integer(value) and is_integer(destination) and is_integer(index) do
    Memory.supply_constant(value, to, destination, index)
    IO.puts("supply_constant")
  end

  defp hrr(["I-REACT", [from, value]])
  when is_integer(value) do
    IO.puts("react")
  end

  defp hrr(["I-CONSUME", [from, value], index])
  when is_integer(value) and is_integer(index) do
    IO.puts("consume")
  end

  defp hrr(["I-SINK", [from, value], index])
  when is_integer(value) and is_integer(index) do
    IO.puts("sink")
  end

  # We need to know how many source, sinks, dti and rti the reaktor has to prepare memory:
  # eg: one dtmblock = {naam-reactor, sources, deployment-time values, reaction-time values, sinks}
  # where dtv and rtv are empty for native reaktors.

  # ALLOCATE = make dtm block for the native reacotr
  # LOOKUP = find signal in signal_table

  # SUPPLY = supply arg1 to arg2 on index arg3 =>
  # arg1 can be constant value OR value of reaction instruction to be found in (RREF 1)
  # arg2 is deployment instruction to be found in DREF = deployement memory.
  # arg3 is the source number for that deployment instruction (which input of the reaktor should get this value)

  # REACT = apply the reaktor, store result in reaktor sink =>
  # for native reaktor = apply reactor on sources and stor result in sink.
  # for user defined reactor = expand call stack with the addres of nested reactor.
end
