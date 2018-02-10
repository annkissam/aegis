defmodule User do
  defstruct [id: nil]
end

defmodule Puppy do
  defstruct [id: nil, user_id: nil, hungry: false]
end

defmodule Puppy.Policy do
  @behaviour Aegis.Policy

  def sanction(%User{id: id}, :show, %Puppy{user_id: user_id}) when id == user_id, do: true
  def sanction(_user, :show, _puppy), do: false

  def sanction(_user, :index, _puppy), do: true

  def scope(_user, _scope, :index), do: :index_scope
  def scope(_user, _scope, :show), do: :show_scope
end

defmodule Kitten do
  defstruct [id: nil, user_id: nil, hungry: false]
end


ExUnit.start()
