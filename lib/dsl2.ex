defmodule Dsl2 do
  # Callback invoked by `use`.
  defmacro __using__(_opts) do
    quote do
      import Dsl2
    end
  end

  defmacro cute_dsl(do: block) do
    quote do
      # extract relevant information
      blk = unquote(block)

      task = Keyword.get(blk, :task)
      reaktor = Keyword.get(blk, :reactor)
      node = Keyword.get(blk, :node)
      connector1 = Keyword.get(blk, :connector1)
      connector2 = Keyword.get(blk, :connector2)
      sinks = Keyword.get(blk, :sink)

      # send information for execution
      Distribution.execute_action(node, reaktor,[connector1,connector2],sinks)

    end
  end


end
