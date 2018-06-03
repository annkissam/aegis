defmodule Puppy.Policy do
  @behaviour Aegis.Policy

  def authorized?(_user, {:index, _puppy}), do: true
  def authorized?(%User{id: id}, {:show, %Puppy{user_id: id}}), do: true
  def authorized?(_user, {:show, _puppy}), do: false

end
