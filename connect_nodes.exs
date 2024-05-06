# call me from iex with: Code.eval_file("connect_nodes.exs")


# Nodes to connect to
nodes_to_connect = [:'node2@0.0.0.0', :'node3@0.0.0.0', :'node4@0.0.0.0', :'node5@0.0.0.0']

# Connect to each node
Enum.each(nodes_to_connect, fn node ->
  Node.connect(node)
end)
