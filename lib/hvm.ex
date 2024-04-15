defmodule Hvm do
  # definitions

  # module attributes, can only be static.
  @native_reactor_table %{plus: fn a, b -> a + b end, minus: fn a, b -> a - b end}
  @source_and_sink_native_reactor_table %{plus: {2, 1}, minus: {2, 1}}
  # @signal_table %{time: fn -> Time.utc_now() end}
  @signal_table %{time: 33}
  @sources %{1 => 0, 2 => 0}

  # Start the VM for received byte code
  def run_VM(reactor_byte_code) do
    # reactors_catalog: key = reactor_name and value = {nos_src, nos_snk, dti, rti}.
    {:ok, reactors_catalog} = catalog_reactors(reactor_byte_code)

    # read all reactors dti, prepare dtm blocks, deploy and store key:reactor_name, value: deployment_pid.
    deployment_pids =
      Enum.reduce(reactors_catalog, %{}, fn {reactor_name, reactor}, deployment_pids ->
        # pattern match reactor
        {nos_src, nos_snk, dti, rti} = reactor
        # transform deployment-time-instrcutions (dti) into deployment-time-memroy (dtm)
        dtm_blocks = make_dtm_blocks(dti, reactors_catalog)
        # deploy the reactor (start genserver for this reactor) and receive pid
        deployment_pid = deploy_reaktor(dtm_blocks, List.duplicate(nil, length(rti)), rti)
        # update deployment_pids key:reactor_name value:deployment_pid
        updated_deployment_pids = Map.put(deployment_pids, reactor_name, deployment_pid)

        updated_deployment_pids
      end)

    IO.inspect(deployment_pids)

    # Loads each deployment pid in all deployments, each deployment knows the pid of all other deployments.
    Enum.each(deployment_pids, fn {_reactor_name, deployment_pid} ->
      Memory.load_pids(deployment_pid, deployment_pids)
    end)

    main_pid = Map.get(deployment_pids, :main)
    # TODO: check for sources and push into deployment
    Memory.set_src(main_pid, [0,1,2,3])
    Memory.show_state(main_pid)
    run_rti(main_pid)
    # TODO: read sink and push forward? before next itteration of run_rti
    IO.puts("vm stopped")

  end

  # Help to run start
  def run_start do
    # test reactor:
    pto = [
      [
        :main,
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
        :main,
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

    run_VM(mt)
  end

  # Make key value map, key = reactor_name and value = reactor -> {nos_src, nos_snk, dti, rti}.
  defp catalog_reactors([], reactors_catalog \\ %{}), do: {:ok, reactors_catalog}

  defp catalog_reactors([[name, nos_src, nos_snk, dti, rti] | tail], reactors_catalog) do
    # add reactor to the map.
    updated_reactors_catalog = Map.put(reactors_catalog, name, {nos_src, nos_snk, dti, rti})

    # recurse and accumulate...
    catalog_reactors(tail, updated_reactors_catalog)
  end

  # make deployment time memory (dtm) blocks and define reactor type: user_defined or native
  defp make_dtm_blocks([], _reactors, acc \\ []), do: Enum.reverse(acc)

  defp make_dtm_blocks([["I-ALLOCMONO", name] | rest], reactors, acc) do
    # load rti into dtm block, if rti not found, state :native to show this is a native reactor.
    type =
      if Map.has_key?(reactors, name) do
        :user_defined
      else
        :native
      end

    # make the dtm block
    block = {name, [nil], [], type, [nil]}
    # recurse for each dtm block to be allocated
    make_dtm_blocks(rest, reactors, [block | acc])
  end

  # Deploy the reaktor
  defp deploy_reaktor(dtm, rtm, rti) do
    case Memory.start_link(dtm, rtm, rti, %{}, [0], [0]) do
      {:ok, pid} ->
        # Use the pid here
        IO.puts("GenServer started with PID: #{inspect(pid)}")
        pid

      {:error, reason} ->
        IO.puts("Failed to start GenServer: #{reason}")
    end
  end

  # Run reaction-time-instructions (rti)
  def run_rti(pid) do
    # retrieve the reaction time instrcutions
    rti = Memory.get_rti(pid)

    # execute rti once.
    case rti do
      {:ok, rti} ->
        Enum.each(Enum.with_index(rti), fn
          {instruction, rti_index} ->
            handle_instruction(instruction, rti_index, pid)
            Memory.show_state(pid)

          {:error, reason} ->
            IO.puts("Error: #{reason}")
        end)

    end
  end


  # recognize the instruction and call appropriate function in Memory module

  def handle_instruction(["I-LOOKUP", signal], rti_index, pid) do
    value = Map.get(@signal_table, signal)
    # t = System.os_time()
    # idex 1 hardcoded.
    case Memory.save_lookup(rti_index, value, pid) do
      :ok -> IO.puts("lookup, rti_index: #{rti_index}")
      _ -> IO.puts("save_lookup failed")
    end
  end

  def handle_instruction(["I-SUPPLY", [from, value], [to, destination], index], rti_index, pid)
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    case Memory.supply_from_location(from, value, to, destination, index, pid) do
      :ok -> IO.puts("supply_from_location, rti_index: #{rti_index}")
      _ -> IO.puts("supply_from_location failed")
    end
  end

  def handle_instruction(["I-SUPPLY", value, [to, destination], index], rti_index, pid)
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    case Memory.supply_constant(value, to, destination, index, pid) do
      :ok -> IO.puts("supply_constant, rti_index: #{rti_index}")
      _ -> IO.puts("supply_constant failed")
    end
  end

  def handle_instruction(["I-REACT", [at, at_index]], rti_index, pid) when is_integer(at_index) do
    case Memory.react(at, at_index, rti_index, pid) do
      :ok ->
        IO.puts("react, rti_index: #{rti_index}")

      _ ->
        IO.puts("react failed")
    end
  end

  def handle_instruction(["I-CONSUME", [from, from_index], sink_index], rti_index, pid)
      when is_integer(from_index) and is_integer(sink_index) do
    case Memory.consume(from, from_index, sink_index, rti_index, pid) do
      :ok -> IO.puts("consume, rti_index: #{rti_index}")
      _ -> IO.puts("consume failed")
    end
  end

  def handle_instruction(["I-SINK", [from, from_index], sink_index], rti_index, pid)
      when is_integer(from_index) and is_integer(sink_index) do
    case Memory.sink(from, from_index, sink_index, rti_index, pid) do
      :ok -> IO.puts("sink, rti_index: #{rti_index}")
      _ -> IO.puts("sink failed")
    end
  end
end
