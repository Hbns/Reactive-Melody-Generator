defmodule DslRun do
  use Dsl

  def run do
    cluster_dsl do
      # small example to declaratively deploy reactors on specific nodes
      # could be seen as a datastructure parsed form a file.
      # this format is handy to add or remove things, together with adapting dsl.ex
      [
        [
          task: :deploy,
          reactor: :p1,
          node: :'node2@0.0.0.0',
          connector1: :f4,
          connector2: :t1,
          sinks: :s1
        ],
        [
          task: "deploy",
          reactor: :p1,
          node: :'node3@0.0.0.0',
          connector1: :f1,
          connector2: :t2,
          sinks: :s1
        ],
        [
          task: :daploy,
          reactor: :p1,
          node: :'node4@0.0.0.0',
          connector1: :f2,
          connector2: :t2,
          sinks: :s1
        ]
      ]
    end
  end
end
