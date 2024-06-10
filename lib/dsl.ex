defmodule Dsl do
  # Callback invoked by `use`.
  defmacro __using__(_opts) do
    quote do
      import Dsl
    end
  end

  # Valid argument lists here
  @valid_tasks [:start, :stop, :restart, :deploy]
  @valid_reactors [:p1]
  @valid_nodes [:'node2@0.0.0.0', :'node3@0.0.0.0', :'node4@0.0.0.0', :'node5@0.0.0.0']
  @valid_connectors [:f1, :f2, :f3, :f4, :t1, :t2]
  @valid_sinkers [:s1]

  # takes a block of deployments and starts each block in the cluster.
  defmacro cluster_dsl(do: block) do
    quote do

      # extract relevant information for each deployment
      blk = unquote(block)
      Enum.each(blk, fn b ->
        task = Keyword.get(b, :task)
        reactor = Keyword.get(b, :reactor)
        node = Keyword.get(b, :node)
        connector1 = Keyword.get(b, :connector1)
        connector2 = Keyword.get(b, :connector2)
        sinks = Keyword.get(b, :sinks)

      # Verify each argument for validity

        if task not in unquote(@valid_tasks) do
            errors = errors + 1

          IO.puts(
            "Error: Task #{inspect(task)} is not a valid TASK in deployment #{inspect(b)}. Valid tasks are: #{inspect(unquote(@valid_tasks))}"
          )
          IO.inspect(errors, label: 'errors: ')
        end
        IO.inspect(errors, label: 'errors outside : ')
        if reactor not in unquote(@valid_reactors) do
          errors = errors + 1
          IO.puts(
            "Error: Reactor #{inspect(reactor)} is not a valid REACTOR in deployment #{inspect(b)}. Valid tasks are: #{inspect(unquote(@valid_reactors))}"
          )
        end

        if node not in unquote(@valid_nodes) do
          errors = errors + 1
          IO.puts(
            "Error: Node #{inspect(node)} is not a valid NODE in deployment #{inspect(b)}. Valid tasks are: #{inspect(unquote(@valid_nodes))}"
          )
        end

        if connector1 not in unquote(@valid_connectors) do
          errors = errors + 1
          IO.puts(
            "Error: Connector #{inspect(connector1)} is not a valid CONNECTOR in deployment #{inspect(b)}. Valid tasks are: #{inspect(unquote(@valid_connectors))}"
          )
        end

        if connector2 not in unquote(@valid_connectors) do
          errors = errors + 1
          IO.puts(
            "Error: Connector #{inspect(connector2)} is not a valid CONNECTOR in deployment #{inspect(b)}. Valid tasks are: #{inspect(unquote(@valid_connectors))}"
          )
        end

        if sinks not in unquote(@valid_sinkers) do
          errors = errors + 1
          IO.puts(
            "Error: Sinks #{inspect(sinks)} is not a valid SINKS in deployment #{inspect(b)}. Valid tasks are: #{inspect(unquote(@valid_sinkers))}"
          )
        end

            if errors == 0 do
              IO.puts("configuration has been send for deployment")
              # Distribution.execute_action(node, reactor, connector1, connector2, sinks)
            else
              IO.puts("errors, did not deploy")
            end
      end)
    end
  end
end
