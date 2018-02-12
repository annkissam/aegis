defmodule Pets.Policy.PuppyPolicy do
  use Aegis.Policy

  def sanction(_, Pets.Puppy, :get, [1]) do
    true
  end

  def sanction(accessor, mod, fun, args) do
    false
  end
end
