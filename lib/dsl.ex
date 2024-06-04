defmodule Dsl do
  # Callback invoked by `use`.
  defmacro __using__(_opts) do
    quote do
      import Dsl
    end
  end

  # takes a block of deployments and starts each block in the cluster.
  defmacro cluster_dsl(do: block) do
    quote do
      # extract relevant information
      blk = unquote(block)
      # handle each deployemtn in blk
      Enum.each(blk, fn b ->
        task = Keyword.get(b, :task)
        reaktor = Keyword.get(b, :reactor)
        node = Keyword.get(b, :node)
        connector1 = Keyword.get(b, :connector1)
        connector2 = Keyword.get(b, :connector2)
        sinks = Keyword.get(b, :sinks)

        # send information for execution
        Distribution.execute_action(node, reaktor, connector1, connector2, sinks)
      end)
    end
  end
end
