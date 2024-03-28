defmodule Hvm do
  # definitions

  # module attributes, can only be static.
  @native_reactor_table %{plus: fn a, b -> a + b end, minus: fn a, b -> a - b end}
  @source_and_sink_native_reactor_table %{plus: {2, 1}, minus: {2, 1}}
  # @signal_table %{time: fn -> Time.utc_now() end}
  @signal_table %{time: 33}
  @sources %{1 => 0, 2 => 0}

  # Start the reaktor orm byte code
  def start(reactor_byte_code) do
    # rti_catalog of reactor_name and reactor_reaction time instructions.
    {:ok, rti_catalog} = catalog_rti(reactor_byte_code)
    # contains all reactors, starting with main,
    # only need the main since it has rti for all other reactors in dtm??
    {:ok, reactors} = match_reactors(reactor_byte_code, rti_catalog)
    [{_name, dtm_blocks, [], rti} | _tail] = reactors

    # IO.inspect(rti_catalog)

    # [name, number_of_sources, number_of_sinks, dti, rti] = reactor_byte_code
    # rb = make_dtm_block(name, number_of_sources, dti, rti, number_of_sinks)
    # asumes dti are only allocmono for native reactors!
    # nb = make_native_dtm_blocks(dti)
    # arguments are (dtm,rtm,rti)
    run_reaktor(dtm_blocks, List.duplicate(0, length(rti)), rti)
  end

  # Help to run start
  def run_start do
    # test reactor:
    pto = [
      [
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
    ]

    mt = [
      [
        :plus_time_one,
        1,
        1,
        [["I-ALLOCMONO", :plus], ["I-ALLOCMONO", :plus]],
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
      ],
      [
        :plus_time_five,
        1,
        1,
        [["I-ALLOCMONO", :plus], ["I-ALLOCMONO", :plus]],
        [
          ["I-LOOKUP", :time],
          ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
          ["I-REACT", ["%DREF", 1]],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SUPPLY", ["%RREF", 5], ["%DREF", 2], 1],
          ["I-SUPPLY", 5, ["%DREF", 2], 2],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SINK", ["%RREF", 9], 1]
        ]
      ],
      [
        :min_time,
        2,
        1,
        [
          ["I-ALLOCMONO", :plus_time_one],
          ["I-ALLOCMONO", :plus_time_five],
          ["I-ALLOCMONO", :minus]
        ],
        [
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 1],
          ["I-REACT", ["%DREF", 1]],
          ["I-SUPPLY", ["%SRC", 2], ["%DREF", 2], 1],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SUPPLY", ["%RREF", 5], ["%DREF", 3], 1],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SUPPLY", ["%RREF", 7], ["%DREF", 3], 2],
          ["I-REACT", ["%DREF", 3]],
          ["I-CONSUME", ["%DREF", 3], 1],
          ["I-SINK", ["%RREF", 10], 1]
        ]
      ]
    ]

    # reverse the bytecode list to start with the 'main' reactor
    # We assume the program is written with the main reactor as last and the first reactor as first!!
    start(mt)
  end

  # Match the reactors in the given program (list of reactors)
  def match_reactors([], _rti_catalog, reactors \\ []), do: {:ok, reactors}

  def match_reactors([[name, _num_src, _num_snk, dti, rti] | tail], rti_catalog, reactors) do
    # make deployment time memory (dtm) blocks for the reactor.
    dtm_blocks = make_dtm_blocks(dti, rti_catalog)

    # store the dtm blocks in dtm memory.
    updated_reactors = [{name, dtm_blocks, [], rti} | reactors]

    # recurse and accumulate...
    match_reactors(tail, rti_catalog, updated_reactors)
  end

  # Make key value map, key: reactor name, value: reaction time instructions(rti)
  def catalog_rti([], rti_catalog \\ %{}), do: {:ok, rti_catalog}

  def catalog_rti([[name, num_src, num_snk, dti, rti] | tail], rti_catalog) do
    # add rti to the map.
    updated_rti_catalog = Map.put(rti_catalog, name, rti)

    # recurse and accumulate...
    catalog_rti(tail, updated_rti_catalog)
  end

  # make deployment time memory (dtm) blocks
  defp make_dtm_blocks([], _rti_catalog, acc \\ []), do: Enum.reverse(acc)

  defp make_dtm_blocks([["I-ALLOCMONO", name] | rest], rti_catalog, acc) do
    # load rti into dtm block, if rti not found, state :native to show this is a native reactor.
    rti = Map.get(rti_catalog, name, :native)
    # make the dtm block
    block = {name, [0], [], rti, [0]}
    # recurse for each dtm block to be allocated
    make_dtm_blocks(rest, rti_catalog, [block | acc])
  end

  # Run the reaktor
  defp run_reaktor(dtm, rtm, rti) do
    # reset the genserver (state) when starting
    case GenServer.whereis(:memory) do
      nil ->
        IO.puts("GenServer :memory is not running, starting now...")

      pid ->
        GenServer.stop(:memory)

        IO.puts(
          "GenServer :memory (PID: #{inspect(pid)}) stopped successfully, restarting now..."
        )
    end

    Memory.start_link(dtm, rtm, [1, 2, 3, 4], [0])
    Memory.show_state()
    # I use sleeps to print nicely in console..
    # Process.sleep(1000)
    # execute each rti

    Enum.each(Enum.with_index(rti), fn {instruction, rti_index} ->
      hrr(instruction, rti_index)
      Memory.show_state()
      Process.sleep(100)
    end)
  end

  # Help running the reactor = hrr
  # recognize the instruction and call appropriate function in Memory module

  def hrr(["I-LOOKUP", signal], rti_index) do
    value = Map.get(@signal_table, signal)
    # t = System.os_time()
    # idex 1 hardcoded.
    Memory.save_lookup(1, value)
    IO.puts("lookup, rti_index: #{rti_index}")
  end

  def hrr(["I-SUPPLY", [from, value], [to, destination], index], rti_index)
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    Memory.supply_from_location(from, value, to, destination, index)
    IO.puts("supply_from_location, rti_index: #{rti_index}")
  end

  def hrr(["I-SUPPLY", value, [to, destination], index], rti_index)
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    Memory.supply_constant(value, to, destination, index)
    IO.puts("supply_constant, rti_index: #{rti_index}")
  end

  # this is a call into genserver (not cast)
  def hrr(["I-REACT", [at, at_index]], rti_index) when is_integer(at_index) do
    case Memory.react(at, at_index) do
      :ok ->
        IO.puts("react succeeded, rti_index: #{rti_index}")

      _ ->
        IO.puts("react failed")
    end
  end

  def hrr(["I-CONSUME", [from, from_index], sink_index], rti_index)
      when is_integer(from_index) and is_integer(sink_index) do
    Memory.consume(from, from_index, sink_index, rti_index)
    IO.puts("consume, rti_index: #{rti_index}")
  end

  def hrr(["I-SINK", [from, from_index], sink_index], rti_index)
      when is_integer(from_index) and is_integer(sink_index) do
    Memory.sink(from, from_index, sink_index, rti_index)
    IO.puts("sink, rti_index: #{rti_index}")
  end
end
