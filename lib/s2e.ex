defmodule S2e do
  @moduledoc """
  Documentation for `S2e`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> S2e.hello()
      :world

  """
  def hello do
    :world
  end

  def add_and_increment(input) do
    current_time = System.os_time()
    result = current_time + input
    result + 1
  end
end
