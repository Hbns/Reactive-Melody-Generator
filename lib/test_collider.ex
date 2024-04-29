defmodule Test_collider do

  def start() do
    SuperCollider.start()
  end
  # SuperCollider.start(ip: '192.168.178.25')


  def play(f, d, n) do
    IO.inspect(f, label: "freq: ")
    IO.inspect(d, label: "dura: ")
    SuperCollider.command(:s_new, ["note_player", n, 1, 0, ["freq", f, "amp", 0.1, "dur", d / 1000]])

  end

end

# jampa actuator functie
#

# SuperCollider.command(:s_new, ["note_player", 100, 1, 0, ["freq", 426, "amp", 0.1]])
#SuperCollider.command(:n_set, [100, ["gate", 1]])
