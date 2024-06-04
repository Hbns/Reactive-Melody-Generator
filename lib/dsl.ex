defmodule Dsl do
  # Callback invoked by `use`.
  #
  # For now it returns a quoted expression that
  # imports the module itself into the user code.
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Dsl

    end
  end

  defmacro execute_dsl(do: block) do
    quote do
      unquote(block)
      #p = Dsl.parse_dsl(block)
      #a = Dsl.execute_actions(p)
      IO.inspect(block, label: 'block: ')
    end
  end

  defp parse_dsl(content) do
    content
    |> Enum.map(&parse_line/1)
  end

  def parse_line({key, value}) do
    {key, value}
  end

  def execute_actions(actions) do
    task = Keyword.get(actions, :task)
    reactor = Keyword.get(actions, :reactor)
    node = Keyword.get(actions, :node)
    source_connector1 = Keyword.get(actions, :source1)
    source_connector2 = Keyword.get(actions, :source2)
    sinks = Keyword.get(actions, :sinks)

    execute_actiont(node, reactor, source_connector1, source_connector2, sinks)
  end

  def execute_actiont(node_name, byte_code, source_connector1, source_connector2, handle_sinks) do
    IO.inspect(node_name, label: 'node_name: ')
    IO.inspect(byte_code, label: 'byte_code: ')
    IO.inspect(source_connector1, label: 'src_conector1: ')
    IO.inspect(source_connector2, label: 'src_conector2: ')
    IO.inspect(handle_sinks, label: 'handle_sinks: ')
  end


  def execute_action(node_name, byte_code, source_connector, handle_sinks) do
    # reactor_byte_code
    rb = apply(__MODULE__, byte_code, [])
    # connecting functions
    connecting = %{
      f1: &Distribution.pick_base_frequency/0,
      f2: &Distribution.pick_base_frequency2/0,
      f3: &Distribution.pick_base_frequency3/0,
      f4: &Distribution.pick_base_frequency4/0,
      t1: &Distribution.pick_tempo/0,
      t2: &Distribution.pick_tempo2/0,
      s1: &Distribution.play_sc/2
    }

    # source_connector
    sc = Enum.map(source_connector, &Map.get(connecting, &1))
    # handles only two connectors for now.
    [sc1, sc2 | _rest] = sc
    # handle_sinks
    hs = connecting[handle_sinks]
    # Start the VM on the specified node with its arguments
    startVM(node_name, rb, sc1, sc2, hs)
  end

  # Mock function for the bytecode
  defp p1, do: "Reactor Byte Code for p1"

  # Mock function for starting the VM
  defp startVM(node_name, rb, sc1, sc2, hs) do
    IO.inspect(node_name, label: "Node Name")
    IO.inspect(rb, label: "Reactor Byte Code")
    IO.inspect(sc1, label: "Source Connector 1")
    IO.inspect(sc2, label: "Source Connector 2")
    IO.inspect(hs, label: "Handle Sinks")
  end
end
