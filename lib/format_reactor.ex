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
# haai version:
  #(
  #  (defr (plus_time_one a)
  #  (def x (+ time a))
  #  (out (+ x 1)))

  # (defr (plus_time_five b)
  #  (def x (+ time b))
  #  (out (+ x 5)))

  # (defr (minus_time a b)
  #   (def x (plus_time_one a))
  #   (def y (plus_time_five b))
  #     (out (- y x)))

  # )
# compiled to byte code
 # ((%R plus_time_one ((I-ALLOCMONO +) (I-ALLOCMONO +)) ((I-LOOKUP time) (I-SUPPLY (%RREF 1) (%DREF 1) 1) (I-SUPPLY (%SRC 1) (%DREF 1) 2) (I-REACT (%DREF 1)) (I-CONSUME (%DREF 1) 1) (I-SUPPLY (%RREF 5) (%DREF 2) 1) (I-SUPPLY 1 (%DREF 2) 2) (I-REACT (%DREF 2)) (I-CONSUME (%DREF 2) 1) (I-SINK (%RREF 9) 1)))
 # (%R plus_time_five ((I-ALLOCMONO +) (I-ALLOCMONO +)) ((I-LOOKUP time) (I-SUPPLY (%RREF 1) (%DREF 1) 1) (I-SUPPLY (%SRC 1) (%DREF 1) 2) (I-REACT (%DREF 1)) (I-CONSUME (%DREF 1) 1) (I-SUPPLY (%RREF 5) (%DREF 2) 1) (I-SUPPLY 5 (%DREF 2) 2) (I-REACT (%DREF 2)) (I-CONSUME (%DREF 2) 1) (I-SINK (%RREF 9) 1)))
 # (%R minus_time ((I-ALLOCMONO plus_time_one) (I-ALLOCMONO plus_time_five) (I-ALLOCMONO -)) ((I-SUPPLY (%SRC 1) (%DREF 1) 1) (I-REACT (%DREF 1)) (I-SUPPLY (%SRC 2) (%DREF 2) 1) (I-REACT (%DREF 2)) (I-CONSUME (%DREF 2) 1) (I-SUPPLY (%RREF 5) (%DREF 3) 1) (I-CONSUME (%DREF 1) 1) (I-SUPPLY (%RREF 7) (%DREF 3) 2) (I-REACT (%DREF 3)) (I-CONSUME (%DREF 3) 1) (I-SINK (%RREF 10) 1))))

# two times plus_time_one deployment:application
