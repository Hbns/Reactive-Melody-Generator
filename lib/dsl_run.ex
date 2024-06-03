defmodule DslRun do
  require Dsl

  def run do
    Dsl.execute_dsl do
      [
        task: :deploy,
        reactor: :p1,
        node: :pick_node,
        connector1: :f1,
        sinks: :s1
      ]
    end
  end
end
