defmodule Memory do
  use GenServer

  # Client

  def start_link(dtm, rtm, rti, pids, src, snk) do
    GenServer.start_link(__MODULE__, {dtm, rtm, rti, pids, src, snk})
  end

  def load_pids(pid, deployment_pids) do
    GenServer.call(pid, {:load_pids, deployment_pids})
  end

  def show_state(pid) do
    GenServer.call(pid, :show_state)
  end

  def show_state_blue(pid) do
    GenServer.cast(pid, :show_state_blue)
  end

  def set_src(pid, new_src) do
    GenServer.call(pid, {:set_src, new_src})
  end

  def get_rti(pid) do
    GenServer.call(pid, :get_rti)
  end

  def save_lookup(at, value, pid) do
    GenServer.call(pid, {:save_lookup, at, value})
  end

  def supply_from_location(from, from_index, to, to_index, to_source, pid) do
    GenServer.call(pid, {:supply, from, from_index, to, to_index, to_source})
  end

  def supply_constant(constant, to, to_index, to_source, pid) do
    GenServer.call(pid, {:supply_constant, constant, to, to_index, to_source})
  end

  def react(at, at_index, rti_index, pid) do
    GenServer.call(pid, {:react, at, at_index, rti_index})
  end

  def consume(from, from_index, sink_index, rti_index, pid) do
    GenServer.call(pid, {:consume, from, from_index, sink_index, rti_index})
  end

  def get_sink(pid, at) do
    GenServer.call(pid, {:get_sink, at})
  end

  def get_sink(pid) do
    GenServer.call(pid, :get_sink)
  end

  def sink(from, from_index, sink_index, rti_index, pid) do
    GenServer.call(pid, {:sink, from, from_index, sink_index, rti_index})
  end

  # Server (callbacks)

  # Initialize memory (Genserver)
  @impl true
  def init({dtm, rtm, rti, pids, src, snk}) do
    {:ok, {dtm, rtm, rti, pids, src, snk}}
  end

  # Show the state of the vm
  @impl true
  def handle_call(:show_state, _from, {dtm, rtm, rti, pids, src, snk}) do
    IO.inspect(dtm, label: "DTM")
    IO.inspect(rtm, label: "RTM")
    IO.inspect(rti, label: "RTI")
    IO.inspect(src, label: "SRC")
    IO.inspect(snk, label: "SNK")
    {:reply, :ok, {dtm, rtm, rti, pids, src, snk}}
  end

  @impl true
  def handle_call({:load_pids, deployment_pids}, _from, {dtm, rtm, rti, pids, src, snk}) do
    {:reply, :ok, {dtm, rtm, rti, deployment_pids, src, snk}}
  end

  @impl true
  def handle_call({:set_src, new_src}, _from, {dtm, rtm, rti, pids, src, snk}) do
    {:reply, :ok, {dtm, rtm, rti, pids, new_src, snk}}
  end

  @impl true
  def handle_call(:get_rti, _from, {dtm, rtm, rti, pids, src, snk}) do
    {:reply, {:ok, rti}, {dtm, rtm, rti, pids, src, snk}}
  end

  # Save a lookup
  @impl true
  def handle_call({:save_lookup, at, value}, _from, {dtm, rtm, rti, pids, src, snk}) do
    updated_rtm = List.insert_at(rtm, at + 1, value)
    {:reply, :ok, {dtm, updated_rtm, rti, pids, src, snk}}
  end

  # Supply value from location
  # i am not using to, dtm is 'hardcoded'
  @impl true
  def handle_call(
        {:supply, from, from_index, to, into_index, to_source},
        _from,
        {dtm, rtm, rti, pids, src, snk}
      ) do
    to_index = into_index - 1

    case from do
      "%SRC" ->
        source_value = Enum.at(src, from_index)

        # We have the source value, put it in the dtm block, but should it not go into the src of that rd?
        case Enum.fetch(dtm, to_index) do
          {:ok, dtm_block} ->
            case dtm_block do
              {name, sources, dti, dtm_rti, sinks} when is_list(sources) ->
                updated_sources = List.insert_at(sources, to_source, source_value)
                updated_dtm_block = {name, updated_sources, dti, dtm_rti, sinks}
                updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
                # get pid en set in src of (user_defined) reaktor deployment
                rd_pid = Map.get(pids, name)

                if dtm_rti != :native do
                  Memory.set_src(rd_pid, [0, source_value])
                end

                {:reply, :ok, {updated_dtm, rtm, rti, pids, src, snk}}

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
              {native, sources, dti, dtm_rti, sinks} when is_list(sources) ->
                updated_sources = List.insert_at(sources, to_source, rtm_value)
                updated_dtm_block = {native, updated_sources, dti, dtm_rti, sinks}
                updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
                {:reply, :ok, {updated_dtm, rtm, rti, pids, src, snk}}

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
  def handle_call(
        {:supply_constant, constant, to, into_index, to_source},
        _from,
        {dtm, rtm, rti, pids, src, snk}
      ) do
    to_index = into_index - 1

    case Enum.fetch(dtm, to_index) do
      {:ok, dtm_block} ->
        case dtm_block do
          {native, sources, dti, dtm_rti, sinks} when is_list(sources) ->
            updated_sources = List.insert_at(sources, to_source, constant)
            updated_dtm_block = {native, updated_sources, dti, dtm_rti, sinks}
            updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
            # IO.inspect(updated_dtm, label: "udtm")
            {:reply, :ok, {updated_dtm, rtm, rti, pids, src, snk}}

          _ ->
            {:error, "dtm_block at position #{to_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{to_index}"}
    end
  end

  # React
  @impl true
  def handle_call({:react, at, at_index, rti_index}, from, {dtm, rtm, rti, pids, src, snk}) do
    case Enum.fetch(dtm, at_index - 1) do
      {:ok, dtm_block} ->
        case dtm_block do
          # dtm block witouth rti (native reactor)
          {name, sources, dti, :native, sink} ->
            # apply the native function
            src1 = Enum.at(sources, 1)
            src2 = Enum.at(sources, 2)
            result = apply_native_operation(name, src1, src2)
            # save result to sink
            updated_sink = List.insert_at(sink, 0, result)
            updated_dtm_block = {name, sources, dti, :native, updated_sink}
            updated_dtm = List.replace_at(dtm, at_index - 1, updated_dtm_block)
            {:reply, :ok, {updated_dtm, rtm, rti, pids, src, snk}}

          # dtm block with rti

          {name, sources, dti, dtm_rti, sink} ->
            pid = Map.get(pids, name)
            # IO.inspect(pid)
            Hvm.run_rti(pid)
            # save the reacted result

            {:ok, result} = get_sink(pid, 0)
            updated_sink = List.insert_at(sink, 0, result)
            updated_dtm_block = {name, sources, dti, dtm_rti, updated_sink}
            updated_dtm = List.replace_at(dtm, at_index - 1, updated_dtm_block)

            {:reply, :ok, {updated_dtm, rtm, rti, pids, src, snk}}

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

  def apply_native_operation(:multiply, src1, src2) do
    res = src1 * src2
    res
  end

  def apply_native_operation(:divide, src1, src2) do
    res = src1 / src2
    res
  end

  # Consume
  @impl true
  def handle_call(
        {:consume, from, from_index, sink_index, rti_index},
        _from,
        {dtm, rtm, rti, pids, src, snk}
      ) do
    case Enum.fetch(dtm, from_index - 1) do
      {:ok, dtm_block} ->
        case dtm_block do
          {_block_name, _sources, _dti, _rti, sink} ->
            consume = Enum.at(sink, sink_index - 1)
            #IO.inspect(consume, label: ~c"consumed_value")
            # place at index, position of this instruction in rti (starts at 1 in haai)
            updated_rtm = List.insert_at(rtm, rti_index + 1, consume)
            # seems to go at the wrong index!?
            #IO.inspect(updated_rtm, label: ~c"UDTM_consume")
            {:reply, :ok, {dtm, updated_rtm, rti, pids, src, snk}}

          _ ->
            {:error, "dtm_block at position #{from_index - 1} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{from_index}"}
    end
  end

  # Sink

  @impl true
  def handle_call(:get_sink, _from, {dtm, rtm, rti, pids, src, snk}) do
    reset_sink = [0]
    {:reply, {:ok, snk}, {dtm, rtm, rti, pids, src, reset_sink}}
  end

  @impl true
  def handle_call({:get_sink, at}, _from, {dtm, rtm, rti, pids, src, snk}) do
    sink = Enum.at(snk, at)
    {:reply, {:ok, sink}, {dtm, rtm, rti, pids, src, snk}}
  end

  @impl true
  def handle_call(
        {:sink, from, from_index, sink_index, rti_index},
        _from,
        {dtm, rtm, rti, pids, src, snk}
      ) do
    sink_value = Enum.at(rtm, rti_index)
    # put sink_value in sink reaktor...
    updated_snk = List.insert_at(snk, sink_index - 1, sink_value)
    {:reply, :ok, {dtm, rtm, rti, pids, src, updated_snk}}
  end
end
