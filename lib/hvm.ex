defmodule Hvm do
  # module attributes, can only be static.
  # @signal_table %{time: fn -> Time.utc_now() end}
  @signal_table %{time: 26, ci: 1.25, lm: 2.0}
  # to check if a reactor is a native one
  @native_table [:plus, :minus, :divide, :multiply]

  # Start the VM for received byte code
  def run_VM(reactor_byte_code, new_source1, new_source2, handle_sink) do
    # reactors_catalog: key = reactor_name and value = {nos_src, nos_snk, dti, rti}.
    {:ok, reactors_catalog} = catalog_reactors(reactor_byte_code)
    # count deployments requested in deployment-time-instructions
    dti_allocations = prepare_deployments(reactors_catalog)
    # remove native deployments
    user_defined_dti_allocations = drop_native_keys(dti_allocations)

    # make deployment-time-blocks for each reactor
    {all_dtm_blocks, updated_user_defined_dti_allocations} =
      Enum.reduce(reactors_catalog, {%{}, user_defined_dti_allocations}, fn {reactor_name,
                                                                             reactor},
                                                                            {dtms_acc, acc} ->
        {_nos_src, _nos_snk, dti, _rti} = reactor
        {dtms, udda} = make_dtm_blocks(dti, acc)
        {Map.put(dtms_acc, reactor_name, dtms), udda}
      end)

    # start all deployments
    deployment_pids =
      Enum.reduce(reactors_catalog, %{}, fn {name, reactor}, pids ->
        # retrieve the run-time-instructions (rti)
        {_nos_src, _nos_snk, _dti, rti} = reactor
        # number of deployment (nod)
        nod = Map.get(user_defined_dti_allocations, name)
        # retrive dtm blocks for reactor
        dtm_blocks = Map.get(all_dtm_blocks, name)

        # make number of deployment (nod) deployments(pid)
        updated_pids =
          if nod == nil do
            # for main reactor, always one deployment nod == nil
            pid = deploy_reaktor(dtm_blocks, List.duplicate(nil, length(rti)), rti)
            Map.put(pids, name, pid)
          else
            # make nod pids and name correctly, as in deployment-time-memory
            Enum.reduce(1..nod, pids, fn i, acc ->
              new_name = String.to_atom(to_string(name) <> "_" <> to_string(i))
              pid = deploy_reaktor(dtm_blocks, List.duplicate(nil, length(rti)), rti)
              Map.put(acc, new_name, pid)
            end)
          end

        # return updated pids
        updated_pids
      end)

    # Loads each deployment pid in all deployments, each deployment knows the pid of all other deployments.
    Enum.each(deployment_pids, fn {_reactor_name, deployment_pid} ->
      Memory.load_pids(deployment_pid, deployment_pids)
    end)

    # use case, reactive melody generator
    # start Supercollider (sound server)
    SuperCollider.start(ip: '192.168.178.25')

    # Start looping the deployment
    # second argument is times to itterate (reactor normaly loops infinitly)
    times_to_itterate = 24
    main_pid = Map.get(deployment_pids, :main)
    loop_deployment(main_pid, times_to_itterate, new_source1, new_source2, handle_sink)

    IO.puts("#{Node.self()} stopped")
  end

  # basecase, to loop n times..
  def loop_deployment(_deployment_pids, 0, _new_source1, _new_source2, _handle_sink) do
    # Base case: when loop count reaches 0, stop looping
    :ok
  end

  def loop_deployment(main_pid, itteration_number, new_source1, new_source2, handle_sink) when itteration_number > 0 do
    # 'receive' stream of input data
    new_src = [0, new_source1.(), new_source2.()]

    # write the newly recieved input into the deployment
    Memory.set_src(main_pid, new_src)
    # run the reaction time instruction of this deployment once
    run_rti(main_pid)
    # 'receive' the sink from last iteration
    {:ok, sinks} = Memory.get_sink(main_pid)

    # main reactor has two sinks:
    frequency = Enum.at(sinks, 0)
    duration = Enum.at(sinks, 1)
    # print some info per itteration
    IO.inspect(itteration_number, label: "#{Node.self()} loop#: ")
    IO.inspect(new_src, label: "#{Node.self()} - srce: ")
    IO.inspect(frequency, label: "#{Node.self()} - freq: ")
    IO.inspect(duration, label: "#{Node.self()} - dura: ")

    node = :rand.uniform(1000) + 1 # node number for supecollider
    # send message to Sc to play sound
    #Test_collider.play(frequency, duration, node)
    handle_sink.(sinks, node)
    # loop at 'musical speed' defined by note duration in sinks
    Process.sleep(trunc(duration) + 50) # added 50 sometimes next note to fast
    # Keep on looping..
    loop_deployment(main_pid, itteration_number - 1, new_source1, new_source2, handle_sink)
  end

  # make a list with 3 random numbers
  def generate_random_numbers do
    [
      Enum.random(44..16860),
      Enum.random(44..16860),
      Enum.random(44..16860)
    ]
  end

  # Consonance in music, is when a combination of notes sounds pleasant...
  def pick_consonant_interval() do
    consonant_intervals = [
      1.0,
      1.0667,
      1.250,
      1.2,
      1.25,
      1.33,
      1.4063,
      1.5,
      1.6,
      1.6667,
      1.8,
      1.8750,
      2.0
    ]

    random_index = :rand.uniform(length(consonant_intervals))
    index = rem(random_index, length(consonant_intervals))
    Enum.at(consonant_intervals, index)
  end

  # multiply the quarternote duration to make other note durations
  def pick_quarter_note_multiplier() do
    quarter_note_multipliers = [8.0, 4.0, 2.0, 1.0, 0.5, 0.25, 0.125]
    random_index = :rand.uniform(length(quarter_note_multipliers))
    index = rem(random_index, length(quarter_note_multipliers))
    Enum.at(quarter_note_multipliers, index)
  end

  # Make key value map, key = reactor_name and value = reactor -> {nos_src, nos_snk, dti, rti}.
  defp catalog_reactors([], reactors_catalog \\ %{}), do: {:ok, reactors_catalog}

  defp catalog_reactors([[name, nos_src, nos_snk, dti, rti] | tail], reactors_catalog) do
    # to keep track how many times a reactor is deployed

    # add reactor to the map.
    updated_reactors_catalog = Map.put(reactors_catalog, name, {nos_src, nos_snk, dti, rti})

    # recurse and accumulate...
    catalog_reactors(tail, updated_reactors_catalog)
  end

  # count for all reactors how many deployments as requested
  def prepare_deployments(reactors_catalog) do
    total_occurrences =
      Enum.reduce(reactors_catalog, %{}, fn {_, reactor}, acc ->
        {_nos_src, _nos_snk, dti, _rti} = reactor
        count = count_occurrences(dti)
        Map.merge(acc, count, fn _key, val1, val2 -> val1 + val2 end)
      end)
  end

  # count for one reactor how many deployments are requetsed
  defp count_occurrences(list) do
    Enum.reduce(list, %{}, fn ["I-ALLOCMONO", name], acc ->
      Map.update(acc, name, 1, &(&1 + 1))
    end)
  end

  # native reactors are deployed differently
  def drop_native_keys(map) do
    # @native_table = [:plus, :minus, :divide, :multiply] # Assuming this module attribute is defined

    Enum.reduce(@native_table, map, fn key, acc ->
      Map.delete(acc, key)
    end)
  end

  # make deployment time memory (dtm) blocks and define reactor type: user_defined or native
  defp make_dtm_blocks([], reactors, acc \\ []), do: {Enum.reverse(acc), reactors}

  defp make_dtm_blocks([["I-ALLOCMONO", name] | rest], reactors, acc) do
    # define reactor type
    type =
      if Map.has_key?(reactors, name) do
        :user_defined
      else
        :native
      end

    ## for number of deployments, make distinct deployment names.
    # how many deployments are required for this reactor?
    times_to_deploy = Map.get(reactors, name)

    # keep track of number of deployments and make distinct name
    new_reactors_and_name =
      if times_to_deploy != nil and times_to_deploy > 0 do
        # add _deployment_number to make the name unique
        new_name = String.to_atom(to_string(name) <> "_" <> to_string(times_to_deploy))
        # lower the number of deployments for this reactor
        {Map.put(reactors, name, times_to_deploy - 1), new_name}
      else
        {reactors, name}
      end

    # extract both items
    {updated_reactors, new_name} = new_reactors_and_name

    # make the dtm block
    block = {new_name, [nil], [], type, [nil]}
    # recurse for each dtm block to be allocated
    make_dtm_blocks(rest, updated_reactors, [block | acc])
  end

  # Deploy the reaktor
  defp deploy_reaktor(dtm, rtm, rti) do
    case Memory.start_link(dtm, rtm, rti, %{}, [0], [0]) do
      {:ok, pid} ->
        # Use the pid here
        # IO.puts("GenServer started with PID: #{inspect(pid)}")
        pid

      {:error, reason} ->
        nil
        # IO.puts("Failed to start GenServer: #{reason}")
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
            # Memory.show_state(pid)
        end)
    end
  end

  # handle instruction will pattern match on the I-INSTRUCTION in the byte code.
  # Memory holds call's to the genserver to perform the instruciton.

  def handle_instruction(["I-LOOKUP", signal], rti_index, pid) do
    value =
      case signal do
        :ci ->
          pick_consonant_interval()

        :lm ->
          pick_quarter_note_multiplier()

        _ ->
          Map.get(@signal_table, signal)
      end

    case Memory.save_lookup(rti_index, value, pid) do
      :ok ->
        log_message = "lookup, rti_index: #{rti_index}\n"
        :ok = write_to_log(log_message)
        :ok

      _ ->
        log_message = "save_lookup failed\n"
        :ok = write_to_log(log_message)
        :error
    end
  end

  def handle_instruction(["I-SUPPLY", [from, value], [to, destination], index], rti_index, pid)
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    case Memory.supply_from_location(from, value, to, destination, index, pid) do
      :ok ->
        log_message = "supply_from_location, rti_index: #{index}\n"
        :ok = write_to_log(log_message)
        :ok

      _ ->
        log_message = "supply_from_location failed\n"
        :ok = write_to_log(log_message)
        :error
    end
  end

  def handle_instruction(["I-SUPPLY", value, [to, destination], index], rti_index, pid)
      when is_integer(value) and is_integer(destination) and is_integer(index) do
    case Memory.supply_constant(value, to, destination, index, pid) do
      :ok ->
        log_message = "supply_constant, rti_index: #{index}\n"
        :ok = write_to_log(log_message)
        :ok

      _ ->
        log_message = "supply_constant failed\n"
        :ok = write_to_log(log_message)
        :error
    end
  end

  def handle_instruction(["I-REACT", [at, at_index]], rti_index, pid) when is_integer(at_index) do
    case Memory.react(at, at_index, rti_index, pid) do
      :ok ->
        log_message = "react, rti_index: #{rti_index}\n"
        :ok = write_to_log(log_message)
        :ok

      _ ->
        log_message = "react failed\n"
        :ok = write_to_log(log_message)
        :error
    end
  end

  def handle_instruction(["I-CONSUME", [from, from_index], sink_index], rti_index, pid)
      when is_integer(from_index) and is_integer(sink_index) do
    case Memory.consume(from, from_index, sink_index, rti_index, pid) do
      :ok ->
        log_message = "consume, rti_index: #{rti_index}\n"
        :ok = write_to_log(log_message)
        :ok

      _ ->
        log_message = "consume failed\n"
        :ok = write_to_log(log_message)
        :error
    end
  end

  def handle_instruction(["I-SINK", [from, from_index], sink_index], rti_index, pid)
      when is_integer(from_index) and is_integer(sink_index) do
    case Memory.sink(from, from_index, sink_index, rti_index, pid) do
      :ok ->
        log_message = "sink, rti_index: #{rti_index}\n"
        :ok = write_to_log(log_message)
        :ok

      _ ->
        log_message = "sink failed\n"
        :ok = write_to_log(log_message)
        :error
    end
  end

  # Log the instruction handles
  defp write_to_log(message) do
    file_path = "log.txt"
    timestamp = :os.system_time(:millisecond)

    formatted_message = "#{timestamp} - #{message}"

    :ok = :file.write_file(file_path, formatted_message, [:append])
    :ok
  end

  # push to supercollider, takes the values and send the osc message to sc
  defp push_to_sc(args) do
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

    mt2 = [
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
        [["I-ALLOCMONO", :plus_time_one], ["I-ALLOCMONO", :plus]],
        [
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 1],
          ["I-REACT", ["%DREF", 1]],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SUPPLY", ["%RREF", 3], ["%DREF", 2], 1],
          ["I-SUPPLY", 5, ["%DREF", 2], 2],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SINK", ["%RREF", 7], 1]
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

    co_nl = [
      [
        :consonance,
        1,
        1,
        [["I-ALLOCMONO", :multiply]],
        [
          ["I-LOOKUP", :ci],
          ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
          ["I-REACT", ["%DREF", 1]],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SINK", ["%RREF", 5], 1]
        ]
      ],
      [
        :note_length,
        1,
        1,
        [["I-ALLOCMONO", :divide], ["I-ALLOCMONO", :multiply]],
        [
          ["I-SUPPLY", 60000, ["%DREF", 1], 1],
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
          ["I-REACT", ["%DREF", 1]],
          ["I-LOOKUP", :lm],
          ["I-SUPPLY", ["%RREF", 4], ["%DREF", 2], 1],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SUPPLY", ["%RREF", 6], ["%DREF", 2], 2],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SINK", ["%RREF", 9], 1]
        ]
      ],
      [
        :main,
        2,
        2,
        [["I-ALLOCMONO", :consonance], ["I-ALLOCMONO", :note_length]],
        [
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 1],
          ["I-REACT", ["%DREF", 1]],
          ["I-SUPPLY", ["%SRC", 2], ["%DREF", 2], 1],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SINK", ["%RREF", 5], 1],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SINK", ["%RREF", 7], 2]
        ]
      ]
    ]

    run_VM(co_nl,22,22,22)
  end
end
