defmodule Memory do
  use GenServer

  # Client

  def start_link(dtm, rtm, src) do
    GenServer.start_link(__MODULE__, {dtm, rtm, src}, name: :memory)
  end

  def show_state do
    GenServer.cast(:memory, :show_state)
  end

  def save_lookup(at, value) do
    GenServer.cast(:memory, {:save_lookup, at, value})
  end

  def supply_from_location(from, from_index, to, to_index, to_source) do
    GenServer.cast(:memory, {:supply, from, from_index, to, to_index, to_source})
  end

  def supply_constant(constant, to, to_index, to_source) do
    GenServer.cast(:memory, {:supply_constant, constant, to, to_index, to_source})
  end

  def react(at, at_index) do
    GenServer.cast(:memory, {:react, at, at_index})
  end

  def consume(from, from_index, sink_index, rti_index) do
    GenServer.cast(:memory, {:consume, from, from_index, sink_index, rti_index})
  end

  def sink(from, from_index, sink_index, rti_index) do
    GenServer.cast(:memory, {:sink, from, from_index, sink_index, rti_index})
  end

  # Server (callbacks)

  @impl true
  def init({dtm, rtm, src}) do
    {:ok, {dtm, rtm, src}}
  end

  @impl true
  def handle_cast(:show_state, {dtm, rtm, src}) do
    IO.inspect(dtm, label: "DTM")
    IO.inspect(rtm, label: "RTM")
    IO.inspect(src, label: "SRC")
    {:noreply, {dtm, rtm, src}}
  end

  @impl true
  def handle_cast({:save_lookup, at, value}, {dtm, rtm, src}) do
    updated_rtm = List.insert_at(rtm, at, value)
    # Print the contents of the lists for verification
    # IO.inspect(dtm, label: "DTM")
    # IO.inspect(updated_rtm, label: "RTM")
    # IO.inspect(src, label: "SRC")
    {:noreply, {dtm, updated_rtm, src}}
  end

  # i am not using to, dtm is 'hardcoded'
  @impl true
  def handle_cast({:supply, from, from_index, to, to_index, to_source}, {dtm, rtm, src}) do
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
                {:noreply, {updated_dtm, rtm, src}}

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
                {:noreply, {updated_dtm, rtm, src}}

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

  @impl true
  def handle_cast({:supply_constant, constant, to, to_index, to_source}, {dtm, rtm, src}) do
    case Enum.fetch(dtm, to_index) do
      {:ok, dtm_block} ->
        case dtm_block do
          {native, sources, dti, rti, sinks} when is_list(sources) ->
            updated_sources = List.insert_at(sources, to_source, constant)
            updated_dtm_block = {native, updated_sources, dti, rti, sinks}
            updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
            IO.inspect(updated_dtm, label: "udtm")
            {:noreply, {updated_dtm, rtm, src}}

          _ ->
            {:error, "dtm_block at position #{to_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{to_index}"}
    end
  end

  @impl true
  def handle_cast({:react, at, at_index}, {dtm, rtm, src}) do
    case Enum.fetch(dtm, at_index) do
      {:ok, dtm_block} ->
        case dtm_block do
          {native, sources, dti, rti, sink} ->
            # apply the native function
            src1 = Enum.at(sources, 1)
            src2 = Enum.at(sources, 2)
            result = apply_native_operation(native, src1, src2)
            # save result to sink
            updated_sink = List.insert_at(sink, 0, result)
            updated_dtm_block = {native, sources, dti, rti, updated_sink}
            updated_dtm = List.replace_at(dtm, at_index, updated_dtm_block)
            {:noreply, {updated_dtm, rtm, src}}

          _ ->
            {:error, "dtm_block at position #{at_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{at_index}"}
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

  @impl true
  def handle_cast({:consume, from, from_index, sink_index, rti_index}, {dtm, rtm, src}) do
    case Enum.fetch(dtm, from_index) do
      {:ok, dtm_block} ->
        case dtm_block do
          {_block_name, _sources, _dti, _rti, sink} ->
            consume = Enum.at(sink, sink_index - 1)
            # place at index, position of this instruction in rti (starts at 1 in haai)
            {:noreply, {dtm, List.insert_at(rtm, rti_index + 1, consume) , src}}

          _ ->
            {:error, "dtm_block at position #{from_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{from_index}"}
    end
  end

  @impl true
  def handle_cast({:sink, from, from_index, sink_index, rti_index}, {dtm, rtm, src}) do

            sink_value = Enum.at(rtm, rti_index)
            # place at index, position of this instruction in rti (starts at 1 in haai)

            IO.puts("returning sink_value: #{sink_value}")
            {:noreply, {dtm, rtm , src}}

  end
end
