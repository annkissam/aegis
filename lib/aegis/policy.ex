defmodule Aegis.Policy do
  @moduledoc """
  Provides behavior that individual policy modules should adopt.

  ## Usage:

  ```
  defmodule SomeResource.Policy do
    @behaviour Aegis.Policy

    def authorize(user, action, resource)
    def scope(user, scope, action)

  end
  ```
  """

  @callback authorize(user :: any, action :: atom, resource :: any) :: boolean

  @callback scope(user :: any, scope :: any, action :: atom) :: any

  @doc """
  This macro allows another module to inherit `Aegis.Policy` behaviour.

  ## Examples:

      iex> defmodule Some.Policy do
      ...>   use Aegis.Policy
      ...>   def authorize(%{admin: true}, _action, _resource), do: true
      ...>   def authorize(%{admin: false, id: id}, _action, %{user_id: user_id}) when id == user_id, do: true
      ...>   def authorize(_user, _action, _resource), do: false
      ...>   def scope(%{admin: true}, _resource_scope, _action), do: :admin_scope
      ...>   def scope(_user, _resource_scope, _action), do: :some_scope
      ...> end
      iex> admin = %{id: 1, admin: true}
      iex> non_admin = %{id: 2, admin: false}
      iex> resource_a = %{user_id: 1}
      iex> resource_b = %{user_id: 2}
      iex> resource_c = %{user_id: 3}
      iex> resource_scope = %{from: "resources"}
      iex> Some.Policy.authorize(admin, nil, resource_a)
      true
      iex> Some.Policy.authorize(admin, nil, resource_b)
      true
      iex> Some.Policy.authorize(admin, nil, resource_c)
      true
      iex> Some.Policy.authorize(non_admin, nil, resource_a)
      false
      iex> Some.Policy.authorize(non_admin, nil, resource_b)
      true
      iex> Some.Policy.authorize(non_admin, nil, resource_c)
      false
      iex> Some.Policy.scope(admin, resource_scope, nil)
      :admin_scope
      iex> Some.Policy.scope(non_admin, resource_scope, nil)
      :some_scope
  """
  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      @callback authorize(user :: any, action :: atom, resource :: any) :: boolean
      def authorize(_, _, _), do: raise "`authorize/3` not defined for #{__MODULE__}"

      @callback scope(user :: any, scope :: any, action :: atom) :: any
      def scope(_, _, _), do: raise "`scope/3` not defined for #{__MODULE__}"

      defoverridable [authorize: 3, scope: 3]
    end
  end
end
