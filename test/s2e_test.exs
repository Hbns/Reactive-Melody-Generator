defmodule S2eTest do
  use ExUnit.Case
  doctest S2e

  test "greets the world" do
    assert S2e.hello() == :world
  end
end
