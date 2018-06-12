defmodule Aegis.Policy do
  @moduledoc """
  Provides behavior that individual policy modules should adopt.

  ## Usage:

  ```
  defmodule SomeResource.Policy do
    @behaviour Aegis.Policy

    def authorized?(requester, {action, resource})

  end
  ```
  """

  @callback authorized?(Aegis.requester_t(), Aegis.request_t()) :: boolean

  @doc """
  This macro allows another module to inherit `Aegis.Policy` behaviour.

  ## Examples:

      iex> defmodule Some.Policy do
      ...>   use Aegis.Policy
      ...>   def authorized?(%{admin: true}, {_action, _resource}), do: true
      ...>   def authorized?(%{admin: false, id: id}, {_action, %{user_id: user_id}}) when id == user_id, do: true
      ...>   def authorized?(_requester, _request), do: false
      ...> end
      iex> admin = %{id: 1, admin: true}
      iex> non_admin = %{id: 2, admin: false}
      iex> resource_a = %{user_id: 1}
      iex> resource_b = %{user_id: 2}
      iex> resource_c = %{user_id: 3}
      iex> Some.Policy.authorized?(admin, {nil, resource_a})
      true
      iex> Some.Policy.authorized?(admin, {nil, resource_b})
      true
      iex> Some.Policy.authorized?(admin, {nil, resource_c})
      true
      iex> Some.Policy.authorized?(non_admin, {nil, resource_a})
      false
      iex> Some.Policy.authorized?(non_admin, {nil, resource_b})
      true
      iex> Some.Policy.authorized?(non_admin, {nil, resource_c})
      false
  """
  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      def authorized?(_, _) do
        raise "`authorize/2` not defined for #{__MODULE__}"
      end

      defoverridable authorized?: 2
    end
  end
end
