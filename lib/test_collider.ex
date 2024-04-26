defmodule Test_collider do

  def start() do
    SuperCollider.start()


  end

  def play() do
    SuperCollider.command(:s_new, ["note_player", 100, 1, 0, ["freq", 328, "amp", 0.1]])

  end

  def plays(f, d) do
    SuperCollider.command(:s_new, ["note_player", 100, 1, 0, ["freq", f, "amp", 0.1, "dur", d]])

  end

  def nfree(node) do
    SuperCollider.command(:n_free, [node])
  end

  def nsetn(f,d) do
    SuperCollider.command(:n_setn, [100, ["freq", f, "amp", 0.1, "dur", d]])
  end

end

# jampa actuator functie
#

# SuperCollider.command(:s_new, ["note_player", 100, 1, 0, ["freq", 426, "amp", 0.1]])
#SuperCollider.command(:n_set, [100, ["gate", 1]])
