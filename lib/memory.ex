defmodule Memory do
  use GenServer

  # Client

  def start_link(dtm, rtm, src, snk) do
    GenServer.start_link(__MODULE__, {dtm, rtm, src, snk})
  end

  def show_state(pid) do
    GenServer.cast(pid, :show_state)
  end
  def show_state_blue(pid) do
    GenServer.cast(pid, :show_state_blue)
  end

  def save_lookup(at, value, pid) do
    GenServer.call(pid, {:save_lookup, at, value})
  end

  def supply_from_location(from, from_index, to, to_index, to_source) do
    GenServer.cast(:memory, {:supply, from, from_index, to, to_index, to_source})
  end

  def supply_constant(constant, to, to_index, to_source) do
    GenServer.cast(:memory, {:supply_constant, constant, to, to_index, to_source})
  end

  def react(at, at_index) do
    GenServer.call(:memory, {:react, at, at_index})
  end

  def consume(from, from_index, sink_index, rti_index) do
    GenServer.cast(:memory, {:consume, from, from_index, sink_index, rti_index})
  end

  def sink(from, from_index, sink_index, rti_index) do
    GenServer.cast(:memory, {:sink, from, from_index, sink_index, rti_index})
  end

  # Server (callbacks)

  # Initialize memory (Genserver)
  @impl true
  def init({dtm, rtm, src, snk}) do
    {:ok, {dtm, rtm, src, snk}}
  end

  # Show the state of the vm
  @impl true
  def handle_cast(:show_state, {dtm, rtm, src, snk}) do
    IO.inspect(dtm, label: "DTM")
    IO.inspect(rtm, label: "RTM")
    IO.inspect(src, label: "SRC")
    IO.inspect(snk, label: "SNK")
    {:noreply, {dtm, rtm, src, snk}}
  end

  @impl true
  def handle_cast(:show_state_blue, {dtm, rtm, src, snk}) do
    blue = IO.ANSI.blue
    reset = IO.ANSI.reset

    IO.inspect(dtm, label: blue <> "DTM" <> reset)
    IO.inspect(rtm, label: blue <> "RTM" <> reset)
    IO.inspect(src, label: blue <> "SRC" <> reset)
    IO.inspect(snk, label: blue <> "SNK" <> reset)

    {:noreply, {dtm, rtm, src, snk}}
  end

  # Save a lookup
  @impl true
  def handle_call({:save_lookup, at, value}, {dtm, rtm, src, snk}) do
    updated_rtm = List.insert_at(rtm, at, value)
    {:reply, :ok, {dtm, updated_rtm, src, snk}}
  end

  # Supply value from location
  # i am not using to, dtm is 'hardcoded'
  @impl true
  def handle_cast({:supply, from, from_index, to, into_index, to_source}, {dtm, rtm, src, snk}) do
    to_index = into_index - 1

    case from do
      "%SRC" ->
        source_value = Enum.at(src, from_index)

        case Enum.fetch(dtm, to_index) do
          {:ok, dtm_block} ->
            case dtm_block do
              {native, sources, dti, rti, sinks} when is_list(sources) ->
                updated_sources = List.insert_at(sources, to_source, source_value)
                updated_dtm_block = {native, updated_sources, dti, rti, sinks}
                updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
                {:noreply, {updated_dtm, rtm, src, snk}}

              _ ->
                {:error, "dtm_block at position #{to_index} does not match the expected format"}
            end

          :error ->
            {:error, "dtm_block not found at position #{to_index}"}
        end

      "%RREF" ->
        rtm_value = Enum.at(rtm, from_index)

        case Enum.fetch(dtm, to_index) do
          {:ok, dtm_block} ->
            case dtm_block do
              {native, sources, dti, rti, sinks} when is_list(sources) ->
                updated_sources = List.insert_at(sources, to_source, rtm_value)
                updated_dtm_block = {native, updated_sources, dti, rti, sinks}
                updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
                {:noreply, {updated_dtm, rtm, src, snk}}

              _ ->
                {:error, "dtm_block at position #{to_index} does not match the expected format"}
            end

          :error ->
            {:error, "dtm_block not found at position #{to_index}"}
        end

      _ ->
        IO.puts("unvalid from #{from}")
    end
  end

  # Supply constant
  @impl true
  def handle_cast({:supply_constant, constant, to, into_index, to_source}, {dtm, rtm, src, snk}) do
    to_index = into_index - 1

    case Enum.fetch(dtm, to_index) do
      {:ok, dtm_block} ->
        case dtm_block do
          {native, sources, dti, rti, sinks} when is_list(sources) ->
            updated_sources = List.insert_at(sources, to_source, constant)
            updated_dtm_block = {native, updated_sources, dti, rti, sinks}
            updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
            IO.inspect(updated_dtm, label: "udtm")
            {:noreply, {updated_dtm, rtm, src, snk}}

          _ ->
            {:error, "dtm_block at position #{to_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{to_index}"}
    end
  end

  # React
  @impl true
  def handle_call({:react, at, at_index}, from, {dtm, rtm, src, snk}) do
    case Enum.fetch(dtm, at_index - 1) do
      {:ok, dtm_block} ->
        case dtm_block do
          # dtm block witouth rti (native reactor)
          {native, sources, dti, :native, sink} ->
            # apply the native function
            src1 = Enum.at(sources, 1)
            src2 = Enum.at(sources, 2)
            result = apply_native_operation(native, src1, src2)
            # save result to sink
            updated_sink = List.insert_at(sink, 0, result)
            updated_dtm_block = {native, sources, dti, :native, updated_sink}
            updated_dtm = List.replace_at(dtm, at_index - 1, updated_dtm_block)
            {:reply, :ok, {updated_dtm, rtm, src, snk}}

          # dtm block with rti
          {name, sources, dti, rti, sink} ->
            IO.puts("react on user defined reactor")

            #Enum.each(Enum.with_index(rti), fn {instruction, rti_index} ->
            #  Hvm.hrr(instruction, rti_index)
            #  Memory.show_state_blue()
            #  Process.sleep(100)
            #end)

            {:reply, :ok, {dtm, rtm, src, snk}}

          _ ->
            {:error, "dtm_block at position #{at_index - 1} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{at_index - 1}"}
    end
  end

  ## Native operations ##
  def apply_native_operation(:plus, src1, src2) do
    res = src1 + src2
    res
  end

  def apply_native_operation(:minus, src1, src2) do
    res = src1 - src2
    res
  end

  # Consume
  @impl true
  def handle_cast({:consume, from, from_index, sink_index, rti_index}, {dtm, rtm, src, snk}) do
    case Enum.fetch(dtm, from_index - 1) do
      {:ok, dtm_block} ->
        case dtm_block do
          {_block_name, _sources, _dti, _rti, sink} ->
            consume = Enum.at(sink, sink_index - 1)
            # place at index, position of this instruction in rti (starts at 1 in haai)
            updated_rtm = List.insert_at(rtm, rti_index + 1, consume)
            {:noreply, {dtm, updated_rtm, src, snk}}

          _ ->
            {:error, "dtm_block at position #{from_index - 1} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{from_index}"}
    end
  end

  # Sink
  @impl true
  def handle_cast({:sink, from, from_index, sink_index, rti_index}, {dtm, rtm, src, snk}) do
    sink_value = Enum.at(rtm, rti_index)
    # put sink_value in sink reaktor...
    updated_snk = List.insert_at(snk, sink_index, sink_value)
    IO.puts("returning sink_value: #{sink_value}")
    {:noreply, {dtm, rtm, src, updated_snk}}
  end
end
