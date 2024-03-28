[
  [:plus_time_one, 1, 1,
  [["I-ALLOCMONO", :plus], ["I-ALLOCMONO", :plus]],
  [["I-LOOKUP", :time], ["I-SUPPLY" ,["%RREF", 1], ["%DREF", 1], 1], ["I-SUPPLY", ["%SRC", 1] ,["%DREF" ,1], 2] ,["I-REACT", ["%DREF", 1]] ,["I-CONSUME", ["%DREF" ,1], 1] ,["I-SUPPLY", ["%RREF", 5] ,["%DREF" ,2] ,1], ["I-SUPPLY", 1 ,["%DREF" ,2] ,2] ,["I-REACT" ,["%DREF" ,2]] ,["I-CONSUME" ,["%DREF" ,2], 1] ,["I-SINK", ["%RREF", 9], 1]]],
  [:plus_time_five, 1, 1,
  [["I-ALLOCMONO", :plus] ,["I-ALLOCMONO", :plus]],
  [["I-LOOKUP", :time], ["I-SUPPLY", ["%RREF", 1] ,["%DREF", 1] ,1], ["I-SUPPLY" ,["%SRC", 1],["%DREF" ,1] ,2],["I-REACT" ,["%DREF" ,1]],["I-CONSUME", ["%DREF" ,1] ,1], ["I-SUPPLY" ,["%RREF", 5] ,["%DREF", 2], 1], ["I-SUPPLY", 5, ["%DREF" ,2], 2] ,["I-REACT", ["%DREF" ,2]], ["I-CONSUME", ["%DREF" ,2], 1] ,["I-SINK", ["%RREF", 9] ,1]]],
  [:min_time, 2, 1,
  [["I-ALLOCMONO", :plus_time_one], ["I-ALLOCMONO", :plus_time_five], ["I-ALLOCMONO", :minus]],

  [["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 1],
  ["I-REACT", ["%DREF", 1]] ,
  ["I-SUPPLY", ["%SRC", 2], ["%DREF", 2], 1],
  ["I-REACT", ["%DREF", 2]] ,
  ["I-CONSUME", ["%DREF", 2] ,1] ,
  ["I-SUPPLY", ["%RREF", 5] ,["%DREF", 3], 1] ,
  ["I-CONSUME", ["%DREF", 1] ,1] ,
  ["I-SUPPLY", ["%RREF" ,7] ,["%DREF", 3] ,2],
  ["I-REACT", ["%DREF", 3]],
  ["I-CONSUME", ["%DREF", 3], 1],
  ["I-SINK", ["%RREF", 10], 1]]]
  ]

  [
    :plus_time_one,
    1,
    1,
    [
      ["I-ALLOCMONO", :plus],
      ["I-ALLOCMONO", :plus]
    ],
    [
      ["I-LOOKUP", :time],
      ["I-SUPPLY", ["%RREF", 1], ["%DREF", 1], 1],
      ["I-SUPPLY", ["%SRC", 1], ["%DREF", 1], 2],
      ["I-REACT", ["%DREF", 1]],
      ["I-CONSUME", ["%DREF", 1], 1],
      ["I-SUPPLY", ["%RREF", 5], ["%DREF", 2], 1],
      ["I-SUPPLY", 1, ["%DREF", 2], 2],
      ["I-REACT", ["%DREF", 2]],
      ["I-CONSUME", ["%DREF", 2], 1],
      ["I-SINK", ["%RREF", 9], 1]
    ]
  ]
