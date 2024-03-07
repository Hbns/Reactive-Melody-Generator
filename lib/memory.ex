defmodule Memory do
  use GenServer

  # Client

  def start_link(dtm, rtm) do
    GenServer.start_link(__MODULE__, {dtm, rtm}, name: :memory)
  end

  def supply_from_location(from, from_index, to, to_index, to_source) do
    GenServer.cast(:memory, {:supply, from, from_index, to, to_index, to_source})
  end

  def supply_constant(constant, to, to_index, to_source) do
    GenServer.cast(:memory, {:supply_constant, constant, to, to_index, to_source})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl true
  def init({dtm, rtm}) do
    {:ok, {dtm, rtm}}
  end

  @impl true
  def handle_call({:add_to_dtm, value}, _from, {dtm, rtm}) do
    {:reply, :ok, {List.insert_at(dtm, -1, value), rtm}}
  end

  @impl true
  def handle_call({:remove_from_dtm, position}, _from, {dtm, rtm}) do
    {:reply, :ok, {List.delete_at(dtm, position), rtm}}
  end

  @impl true
  def handle_cast({:supply_constant, constant, to, to_index, to_source}, {dtm, rtm}) do
    case Enum.fetch(dtm, to_index) do
      {:ok, dtm_block} ->
        case dtm_block do
          {_native, sources, _dti, _rti, sinks} when is_list(sources) ->
            updated_sources = List.insert_at(sources, to_source, constant)
            updated_dtm_block = List.replace_at(dtm_block, 1, updated_sources)
            updated_dtm = List.replace_at(dtm, to_index, updated_dtm_block)
            {:noreply, {updated_dtm, rtm}}

          _ ->
            {:error, "dtm_block at position #{to_index} does not match the expected format"}
        end

      :error ->
        {:error, "dtm_block not found at position #{to_index}"}
    end
  end

  @impl true
  def handle_cast({:remove_from_rtm, position}, {dtm, rtm}) do
    {:noreply, {dtm, List.delete_at(rtm, position)}}
  end
end
