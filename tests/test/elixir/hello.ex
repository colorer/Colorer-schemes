defmodule Hello do
  def greet(name) do
    "hi #{name}"
  end

  def run, do: greet(:world)
end
