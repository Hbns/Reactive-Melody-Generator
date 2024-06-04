defmodule DslRun do
  use Dsl2

  def run do
    cute_dsl do
      [

        task: :deploy,
        reactor: :p1,
        node: :'node3@0.0.0.0',
        connector1: :f1,
        connector1: :f2,
        sinks: :s1

      ]
    end
  end
end
