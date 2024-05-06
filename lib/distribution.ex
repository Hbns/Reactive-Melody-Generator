defmodule Distribution do
  def show_nodes() do
    this_node = Node.self()
    nodes = Node.list()
    IO.inspect(nodes, label: ~c"Shows nodes connected to #{this_node}: ")
  end

  def startVM(remote_node, reactor_bytecode, connect_source1, connect_source2, handle_sink) do
    Node.spawn(remote_node, Hvm, :run_VM, [reactor_bytecode, connect_source1, connect_source2, handle_sink])
  end

  def spawn_to_known_nodes() do
    nodes = Node.list()
    middle_index = Kernel.div(length(nodes), 2)
    {first_part, second_part} = Enum.split(nodes, middle_index)
    Enum.each(first_part, fn node -> startVM(node, p1(), &pick_base_frequency/0, &pick_tempo/0, &play_sc/2) end)
    Enum.each(second_part, fn node -> startVM(node, p1(), &pick_base_frequency2/0, &pick_tempo/0, &play_sc/2) end)
  end

  ## Distributed reactive melody generator ##

  # function used as data stream generator
  def pick_base_frequency() do
    # G Major
    base_frequencies = [432, 242.405, 544.37, 577.83, 324.04, 726.86, 813.74, 864]
    random_index = :rand.uniform(length(base_frequencies))
    index = rem(random_index, length(base_frequencies))
    Enum.at(base_frequencies, index)
  end

  def pick_base_frequency2() do
    base_frequencies = [1000, 2000, 3000, 4000, 5000]
    random_index = :rand.uniform(length(base_frequencies))
    index = rem(random_index, length(base_frequencies))
    Enum.at(base_frequencies, index)
  end

  # function used as data stream generator
  def pick_tempo() do
    tempos = [90, 100, 110, 120, 130, 140, 150]
    random_index = :rand.uniform(length(tempos))
    index = rem(random_index, length(tempos))
    Enum.at(tempos, index)
  end

  def play_sc(sinks, node) do
    Test_collider.play(Enum.at(sinks, 0), Enum.at(sinks, 1), node)
  end

  ## example program ##
  # function to be called from iex to receive bytcode of p1
  def p1 do
    [
      [
        :consonance,
        1,
        1,
        [["I-ALLOCMONO", :multiply]],
        [
          ["I-LOOKUP", :ci],
          ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
          ["I-REACT", ["%DREF", 1]],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SINK", ["%RREF", 5], 1]
        ]
      ],
      [
        :note_length,
        1,
        1,
        [["I-ALLOCMONO", :divide], ["I-ALLOCMONO", :multiply]],
        [
          ["I-SUPPLY", 60000, ["%DREF", 1], 1],
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
          ["I-REACT", ["%DREF", 1]],
          ["I-LOOKUP", :lm],
          ["I-SUPPLY", ["%RREF", 4], ["%DREF", 2], 1],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SUPPLY", ["%RREF", 6], ["%DREF", 2], 2],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SINK", ["%RREF", 9], 1]
        ]
      ],
      [
        :main,
        2,
        2,
        [["I-ALLOCMONO", :consonance], ["I-ALLOCMONO", :note_length]],
        [
          ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 1],
          ["I-REACT", ["%DREF", 1]],
          ["I-SUPPLY", ["%SRC", 2], ["%DREF", 2], 1],
          ["I-REACT", ["%DREF", 2]],
          ["I-CONSUME", ["%DREF", 1], 1],
          ["I-SINK", ["%RREF", 5], 1],
          ["I-CONSUME", ["%DREF", 2], 1],
          ["I-SINK", ["%RREF", 7], 2]
        ]
      ]
    ]
  end

  ## Example Program ##
  p1 = [
    [
      :consonance,
      1,
      1,
      [["I-ALLOCMONO", :multiply]],
      [
        ["I-LOOKUP", :ci],
        ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
        ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
        ["I-REACT", ["%DREF", 1]],
        ["I-CONSUME", ["%DREF", 1], 1],
        ["I-SINK", ["%RREF", 5], 1]
      ]
    ],
    [
      :note_length,
      1,
      1,
      [["I-ALLOCMONO", :divide], ["I-ALLOCMONO", :multiply]],
      [
        ["I-SUPPLY", 60000, ["%DREF", 1], 1],
        ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
        ["I-REACT", ["%DREF", 1]],
        ["I-LOOKUP", :lm],
        ["I-SUPPLY", ["%RREF", 4], ["%DREF", 2], 1],
        ["I-CONSUME", ["%DREF", 1], 1],
        ["I-SUPPLY", ["%RREF", 6], ["%DREF", 2], 2],
        ["I-REACT", ["%DREF", 2]],
        ["I-CONSUME", ["%DREF", 2], 1],
        ["I-SINK", ["%RREF", 9], 1]
      ]
    ],
    [
      :main,
      2,
      2,
      [["I-ALLOCMONO", :consonance], ["I-ALLOCMONO", :note_length]],
      [
        ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 1],
        ["I-REACT", ["%DREF", 1]],
        ["I-SUPPLY", ["%SRC", 2], ["%DREF", 2], 1],
        ["I-REACT", ["%DREF", 2]],
        ["I-CONSUME", ["%DREF", 1], 1],
        ["I-SINK", ["%RREF", 5], 1],
        ["I-CONSUME", ["%DREF", 2], 1],
        ["I-SINK", ["%RREF", 7], 2]
      ]
    ]
  ]
end
