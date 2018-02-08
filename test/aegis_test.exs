defmodule AegisTest do
  use ExUnit.Case
  doctest Aegis

  test "greets the world" do
    assert Aegis.hello() == :world
  end
end
