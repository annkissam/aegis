defmodule Aegis do
  @moduledoc """
  Lightweight, flexible resource authorization.
  """

  @doc """
  Returns `true` if a user is sanctioned to perform an action on a given resource as dictated by the resource's corresponding policy definition.


  ## Example

  ```
  defmodule Puppy do
    defstruct [id: nil, user_id: nil, hungry: false]
  end

  defmodule Puppy.Policy do
    @behaviour Aegis.Policy

    def sanction(_user, :index, _puppy), do: true
  end

  defmodule Kitten do
    defstruct [id: nil, user_id: nil, hungry: false]
  end
  ```

    iex> user = :user
    iex> resource = Puppy
    iex> Aegis.sanctioned?(user, :index, resource)
    true
    iex> Aegis.sanctioned?(user, :show, resource)
    false

    iex> user = :user
    iex> action = :index
    iex> resource = Kitten
    iex> Aegis.sanctioned?(user, action, resource)
    ** (RuntimeError) Policy not found: Elixir.Kitten.Policy
  """
  @spec sanctioned?(user :: any, action :: atom, resource :: any) :: boolean
  def sanctioned?(user, action, resource) do
    resource
    |> fetch_policy_module
    |> sanctioned?(user, action, resource)
  end

  @spec sanctioned?(mod :: module, user :: any, action :: atom, resource :: any) :: boolean
  def sanctioned?(mod, user, action, resource) do
    apply(mod, :sanction, [user, action, resource])
  end

  @spec auth_scope(user :: any, scope :: any, action :: atom) :: any
  def auth_scope(user, scope, action) do
    scope
    |> fetch_policy_module
    |> apply(:scope, [user, scope, action])
  end

  @spec auth_scope(mod :: module, user :: any, scope :: any, action :: atom) :: any
  def auth_scope(mod, user, scope, action) do
    apply(mod, :scope, [user, scope, action])
  end

  @spec fetch_policy_module(any) :: module | :error
  def fetch_policy_module(arg) do
    case Aegis.PolicyFinder.call(arg) do
      {:error, nil} -> raise "No Policy for nil object"
      {:error, mod} -> raise "Policy not found: #{mod}"
      {:ok, mod} -> mod
    end
  end
end
