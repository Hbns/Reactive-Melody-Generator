defmodule Test_collider do
  def start() do
    SuperCollider.start()


  end

  def play() do
    SuperCollider.command(:s_new, ["sine", 100, 1, 0, ["freq", 426]])
    Process.sleep(1000)
    SuperCollider.command(:n_free, 100)

  end
end
