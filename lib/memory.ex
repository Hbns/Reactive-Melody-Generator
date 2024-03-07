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
      {:ok, tuple} -> case tuple do
        {_native, sources, _dti, _rti, sinks} when is_list(sources) ->
        updated_sources = List.insert_at(sources, to_source, constant)
        updated_tuple = List.replace_at(tuple, to_index, updated_sources)
        ## also need to update dtm
        {:ok, updated_tuple}
      end
    end

    {:noreply, {dtm, List.insert_at(rtm, -1, value)}}
  end

  @impl true
  def handle_cast({:remove_from_rtm, position}, {dtm, rtm}) do
    {:noreply, {dtm, List.delete_at(rtm, position)}}
  end
end
