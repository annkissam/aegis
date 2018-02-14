defmodule Puppy.Policy do
  @behaviour Aegis.Policy

  def authorize(%User{id: id}, :show, %Puppy{user_id: id}), do: true
  def authorize(_user, :show, _puppy), do: false

  def authorize(_user, :index, _puppy), do: true

  def scope(_user, _scope, :index), do: :index_scope
  def scope(_user, _scope, :show), do: :show_scope
end
