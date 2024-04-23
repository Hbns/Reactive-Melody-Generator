defmodule Test_collider do

  def start() do
    SuperCollider.start()


  end

  def play() do
    SuperCollider.command(:s_new, ["note_player", 100, 1, 0, ["freq", 328, "amp", 0.1]])
    Process.sleep(500)
    SuperCollider.command(:n_free, 100)
    Process.sleep(500)
    SuperCollider.command(:s_new, ["sine", 100, 1, 0, ["freq", 656, "amp", 0.1]])
    Process.sleep(500)
    SuperCollider.command(:n_free, 100)
    Process.sleep(500)
    SuperCollider.command(:s_new, ["sine", 100, 1, 0, ["freq", 912, "amp", 0.1]])
    Process.sleep(500)
    SuperCollider.command(:n_free, 100)
    Process.sleep(500)

  end

end

# jampa actuator functie
#

# SuperCollider.command(:s_new, ["note_player", 100, 1, 0, ["freq", 426, "amp", 0.1]])
#SuperCollider.command(:n_set, [100, ["gate", 1]])
