defmodule PrimitiveReactors do

  pto = [ :plus_time_one,
  [
    ["I-ALLOCMONO", :plus],
    ["I-ALLOCMONO", :plus]
  ],
  [
    ["I-LOOKUP", "time"],
    ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
    ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
    ["I-REACT", ["%DREF", 1]],
    ["I-CONSUME", ["%DREF", 1], 1],
    ["I-SUPPLY", ["%RREF", 5], ["%DREF", 2], 1],
    ["I-SUPPLY", 1, ["%DREF", 2], 2],
    ["I-REACT", ["%DREF", 2]],
    ["I-CONSUME", ["%DREF", 2],1],
    ["I-SINK", ["%RREF", 9],1]
  ]
]


end
