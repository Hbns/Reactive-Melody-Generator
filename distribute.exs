# Define the number of nodes to start
number_of_nodes = 5

# Start each Elixir node and send a message to it
Enum.each(1..number_of_nodes, fn i ->
  # Start the Elixir node with a unique name
  node_name = "n#{i}@home"
  {:ok, _} = System.cmd("iex", ["--name", node_name, "-S", "mix"])

  # Send a message to the newly started node
  message = {:hello, "world from #{node_name}"}
  send_to_node_command = "Node.send(#{node_name.inspect}, unquote(#{inspect(message)}))"
  System.cmd("iex", ["-e", send_to_node_command])
  IO.flush
end)
