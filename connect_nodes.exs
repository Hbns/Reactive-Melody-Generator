# call me from iex with: Code.eval_file("connect_nodes.exs")


# Nodes to connect to
nodes_to_connect = [:'node2@0.0.0.0', :'node3@0.0.0.0', :'node4@0.0.0.0', :'node5@0.0.0.0', :'node6@0.0.0.0', :'node7@0.0.0.0', :'node8@0.0.0.0', :'node9@0.0.0.0', :'node10@0.0.0.0', :'node11@0.0.0.0']

# Connect to each node
Enum.each(nodes_to_connect, fn node ->
  Node.connect(node)
end)

# initiate SuperCollider on all nodes
#nodes = Node.list()
#Enum.each(nodes, fn node -> SuperCollider.start(ip:'192.168.178.25'))
