# haai code:
#(
#                 (defr (consonance f)
#                  (out (* ci f)))

#                 (defr (note_length bpm)
#                   (def q (/ 60000 bpm))
#                   (out (* lm q)))
#
#                 (defr (main f bpm)
#                   (out (consonance f))
#                   (out (note_length bpm)))
#                )))


co_nl = [
[:consonance, 1, 1,
[["I-ALLOCMONO", :multiply]],
[
  ["I-LOOKUP", :ci],
  ["I-SUPPLY",["%RREF",1],["%DREF",1],1],
  ["I-SUPPLY",["%SRC",1],["%DREF",1],2],
  ["I-REACT",["%DREF",1]],["I-CONSUME",["%DREF",1],1],
  ["I-SINK",["%RREF",5],1]]],
[:note_length, 1, 1,
[["I-ALLOCMONO", :divide],["I-ALLOCMONO", :multiply]],
[
  ["I-SUPPLY",60000,["%DREF",1],1],
  ["I-SUPPLY",["%SRC",1],["%DREF",1],2],
  ["I-REACT",["%DREF",1]],["I-LOOKUP",:lm],
  ["I-SUPPLY",["%RREF",4],["%DREF",2],1],
  ["I-CONSUME",["%DREF",1],1],
  ["I-SUPPLY",["%RREF",6],["%DREF",2],2],
  ["I-REACT",["%DREF",2]],
  ["I-CONSUME",["%DREF",2],1],
  ["I-SINK",["%RREF",9],1]]],
[:main, 2, 2,
[["I-ALLOCMONO", :consonance],["I-ALLOCMONO", :note_length]],
[
  ["I-SUPPLY",["%SRC",1],["%DREF",1],1],
  ["I-REACT",["%DREF",1]],
  ["I-SUPPLY",["%SRC",2],["%DREF",2],1],
  ["I-REACT",["%DREF",2]],
  ["I-CONSUME",["%DREF",1],1],
  ["I-SINK",["%RREF",5],1],
  ["I-CONSUME",["%DREF",2],1],
  ["I-SINK",["%RREF",7],2]
]
]
]
