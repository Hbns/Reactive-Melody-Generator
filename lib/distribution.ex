defmodule Distribution do
  def show_nodes() do
    this_node = Node.self()
    nodes = Node.list()
    IO.inspect(nodes, label: ~c"Shows nodes connected to #{this_node}: ")
  end

  def startVM(remote_node, reactor_bytecode, connect_source1, connect_source2, handle_sink) do
    Node.spawn(remote_node, Hvm, :run_VM, [
      reactor_bytecode,
      connect_source1,
      connect_source2,
      handle_sink
    ])
  end

  def spawn_to_known_nodes() do
    nodes = Node.list()
    middle_index = Kernel.div(length(nodes), 2)
    {first_part, second_part} = Enum.split(nodes, middle_index)

    Enum.each(first_part, fn node ->
      startVM(node, p1(), &pick_base_frequency/0, &pick_tempo/0, &play_sc/2)
    end)

    Enum.each(second_part, fn node ->
      startVM(node, p1(), &pick_base_frequency2/0, &pick_tempo/0, &play_sc/2)
    end)
  end

  def spawn_quarter_note_scale() do
    nodes = Node.list()
    middle_index = Kernel.div(length(nodes), 2)
    {first_part, second_part} = Enum.split(nodes, middle_index)

    Enum.each(first_part, fn node ->
      startVM(node, p1(), &pick_base_frequency3/0, &pick_tempo/0, &play_sc/2)
    end)

    Enum.each(second_part, fn node ->
      startVM(node, p1(), &pick_base_frequency4/0, &pick_tempo2/0, &play_sc/2)
    end)
  end

  ## Distributed reactive melody generator ##

  # function used as data stream
  def pick_base_frequency() do
    # G Major
    base_frequencies = [
      216.00,
      451.25,
      471.15,
      246.25,
      514.25,
      536.75,
      561.00,
      585.88,
      612.75,
      320.25,
      669.25,
      698.25
    ]

    random_index = :rand.uniform(length(base_frequencies))
    index = rem(random_index, length(base_frequencies))
    Enum.at(base_frequencies, index)
  end

  def pick_base_frequency2() do
    base_frequencies = [
      1296.00,
      1350.75,
      1411.50,
      1473.00,
      1540.50,
      1611.00,
      1683.00,
      1761.00,
      1837.50,
      1927.50,
      2016.00,
      2112.00
    ]

    random_index = :rand.uniform(length(base_frequencies))
    index = rem(random_index, length(base_frequencies))
    Enum.at(base_frequencies, index)
  end

  # quarter tone scale
  def pick_base_frequency3() do
    base_frequencies = [
      440.00,
      453.36,
      466.16,
      479.42,
      493.07,
      507.14,
      521.63,
      536.56,
      551.95,
      567.81,
      584.14,
      600.97,
      618.33,
      636.22,
      654.68,
      673.71,
      693.34,
      713.58,
      734.46,
      755.99,
      778.19,
      801.09,
      824.71,
      849.09
    ]

    random_index = :rand.uniform(length(base_frequencies))
    index = rem(random_index, length(base_frequencies))
    Enum.at(base_frequencies, index)
  end

  # quarter tone scale
  def pick_base_frequency4() do
    base_frequencies = [
      880.00,
      906.72,
      933.31,
      959.85,
      986.14,
      1013.49,
      1041.26,
      1069.79,
      1099.28,
      1129.63,
      1160.33,
      1191.95,
      1224.67,
      1257.33,
      1290.94,
      1325.37,
      1360.77,
      1397.21,
      1434.71,
      1473.23,
      1512.79,
      1553.39,
      1595.07,
      1637.82
    ]

    random_index = :rand.uniform(length(base_frequencies))
    index = rem(random_index, length(base_frequencies))
    Enum.at(base_frequencies, index)
  end

  # function used as data stream
  def pick_tempo() do
    tempos = [90, 100, 110, 120, 130, 140, 150]
    random_index = :rand.uniform(length(tempos))
    index = rem(random_index, length(tempos))
    Enum.at(tempos, index)
  end

  def pick_tempo2() do
    tempos = [150, 155, 160, 165, 170, 175, 180, 185, 200]
    random_index = :rand.uniform(length(tempos))
    index = rem(random_index, length(tempos))
    Enum.at(tempos, index)
  end

  # handle sinks function, send values to sc
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
  _p1 = [
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
