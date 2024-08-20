# S2e

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `s2e` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:s2e, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/s2e](https://hexdocs.pm/s2e).

## Start

Make a cluster by running 'StartNodes.sh 1 5' (first node 1, last node 5) in terminal.
Select masternode eg: node1. run 'Code.eval_file("connect_nodes.exs")' to connect masternode to all nodes.

--Cluster is ready

Read .Yaml file to load configuration into cluster.
In folder pyDsl run 'python3 deploy.py config.yaml'
This will make a json file.
Run Distribution.read_and_handle_deployment_info in Elixir, It will read the jason and launch the nodes, if available.


