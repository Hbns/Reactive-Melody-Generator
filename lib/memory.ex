defmodule Memory do
  use GenServer

  # Client

  def start_link(dtm, rtm, src) do
    GenServer.start_link(__MODULE__, {dtm, rtm, src}, name: :memory)
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

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl true
  def init({dtm, rtm, src}) do
    {:ok, {dtm, rtm, src}}
  end

  @impl true
  def handle_call({:add_to_dtm, value}, _from, {dtm, rtm, src}) do
    {:reply, :ok, {List.insert_at(dtm, -1, value), rtm, src}}
  end

  @impl true
  def handle_call({:remove_from_dtm, position}, _from, {dtm, rtm, src}) do
    {:reply, :ok, {List.delete_at(dtm, position), rtm, src}}
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
              {_native, sources, _dti, _rti, sinks} when is_list(sources) ->
                updated_sources = List.insert_at(sources, to_source, source_value)
                updated_dtm_block = List.replace_at(dtm_block, 1, updated_sources)
                updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
                {:noreply, {updated_dtm, rtm}}

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
              {_native, sources, _dti, _rti, sinks} when is_list(sources) ->
                updated_sources = List.insert_at(sources, to_source, rtm_value)
                updated_dtm_block = List.replace_at(dtm_block, 1, updated_sources)
                updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
                {:noreply, {updated_dtm, rtm}}

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
          {_native, sources, _dti, _rti, sinks} when is_list(sources) ->
            updated_sources = List.insert_at(sources, to_source, constant)
            updated_dtm_block = List.replace_at(dtm_block, 1, updated_sources)
            updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
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
          {native, sources, _dti, _rti, sink} ->
            # apply the native function
            [src1 | src2] = sources
            result = apply_native_operation(native, src1, src2)
            # save result to sink
            updated_sink = [result | sink]
            updated_dtm_block = List.replace_at(dtm_block, 4, updated_sink)
            updated_dtm = List.replace_at(dtm, at_index, updated_dtm_block)
            {:noreply, {updated_dtm, rtm, src}}

          _ ->
            {:error, "dtm_block at position #{at_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{at_index}"}
    end
  end

  # table with native operations, default forth argument in apply_native_operation:
  native_operations = %{plus: &Kernel.+/2, minus: &Kernel.-/2}

  def apply_native_operation(operation, src1, src2, native_operations \\ %{}) do
    case Map.fetch(native_operations, operation) do
      {:ok, func} ->
        func.(src1, src2)

      :error ->
        raise ArgumentError, "Invalid operation: #{operation}"
    end
  end

  @impl true
  def handle_cast({:remove_from_rtm, position}, {dtm, rtm}) do
    {:noreply, {dtm, List.delete_at(rtm, position)}}
  end
end
