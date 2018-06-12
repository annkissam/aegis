defmodule Puppy.Policy do
  @behaviour Aegis.Policy

  def authorized?(_user, {:index, _puppy}), do: true
  def authorized?(%User{id: id}, {:show, %Puppy{user_id: id}}), do: true
  def authorized?(_user, {:show, _puppy}), do: false

  def auth_scope(%User{id: user_id}, {:index, scope}) do
    Enum.filter(scope, &(&1.user_id == user_id))
  end
end
