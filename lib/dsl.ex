defmodule Dsl do
  # Callback invoked by `use`.
  defmacro __using__(_opts) do
    quote do
      import Dsl
    end
  end

  # Valid values per field
  @valid_tasks [:start, :stop, :restart, :deploy]
  @valid_reactors [:p1]
  @valid_nodes [:"node2@0.0.0.0", :"node3@0.0.0.0", :"node4@0.0.0.0", :"node5@0.0.0.0"]
  @valid_connectors [:f1, :f2, :f3, :f4, :t1, :t2]
  @valid_sinkers [:s1]

  # Helper function to validate a single field
  def validate_field(value, valid_list, field_name, deployment) do
    if value not in valid_list do
      IO.puts(
        "Error: #{field_name} #{inspect(value)} is not valid in deployment #{inspect(deployment)}. Valid values are: #{inspect(valid_list)}"
      )
      false
    else
      true
    end
  end

  # Main macro to process deployments
  defmacro cluster_dsl(do: block) do
    quote do
      # Extract relevant information for each deployment
      blk = unquote(block)

      Enum.each(blk, fn deployment ->
        task = Keyword.get(deployment, :task)
        reactor = Keyword.get(deployment, :reactor)
        node = Keyword.get(deployment, :node)
        connector1 = Keyword.get(deployment, :connector1)
        connector2 = Keyword.get(deployment, :connector2)
        sinks = Keyword.get(deployment, :sinks)

        # Validate each field and collect errors
        valid_task = Dsl.validate_field(task, unquote(@valid_tasks), "Task", deployment)
        valid_reactor = Dsl.validate_field(reactor, unquote(@valid_reactors), "Reactor", deployment)
        valid_node = Dsl.validate_field(node, unquote(@valid_nodes), "Node", deployment)
        valid_connector1 = Dsl.validate_field(connector1, unquote(@valid_connectors), "Connector1", deployment)
        valid_connector2 = Dsl.validate_field(connector2, unquote(@valid_connectors), "Connector2", deployment)
        valid_sinks = Dsl.validate_field(sinks, unquote(@valid_sinkers), "Sinks", deployment)

        if valid_task and valid_reactor and valid_node and valid_connector1 and valid_connector2 and valid_sinks do
          IO.puts("Configuration has been sent for deployment")
          #Distribution.execute_action(node, reactor, connector1, connector2, sinks)
        else
          IO.puts("Errors encountered, deployment aborted")
        end
      end)
    end
  end
end
