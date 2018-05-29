defmodule Aegis do
  @moduledoc """
  Lightweight, flexible authorization.
  """

  @type requester_t :: Process.t() | any()

  @type request_t :: Tuple.t() | fun()

  @doc """
  Returns `true` if a user is authorized to perform an action on a given resource as dictated by the resource's corresponding policy definition.


  ## Example

  ```
  defmodule Puppy do
    defstruct [id: nil, user_id: nil, hungry: false]
  end

  defmodule Puppy.Policy do
    @behaviour Aegis.Policy

    def authorize(_user, :index, _puppy), do: true
  end

  defmodule Kitten do
    defstruct [id: nil, user_id: nil, hungry: false]
  end
  ```

    iex> user = :user
    iex> resource = Puppy
    iex> Aegis.authorized?(user, :index, resource)
    true
    iex> Aegis.authorized?(user, :show, resource)
    false

    iex> user = :user
    iex> action = :index
    iex> resource = Kitten
    iex> Aegis.authorized?(user, action, resource)
    ** (RuntimeError) Policy not found: Elixir.Kitten.Policy
  """
  @spec authorized?(__MODULE__.requester_t(), __MODULE__.request_t(), module()) :: boolean
  def authorized?(requester, request, policy \\ nil)
  def authorized?(requester, request, nil) do
    authorized?(requester, request, fetch_policy_module(request))
  end
  def authorized?(requester, request, policy) do
    apply(policy, :authorized?, [requester, request])
  end

  defp fetch_policy_module(arg) do
    case __MODULE__.PolicyFinder.call(arg) do
      {:error, nil} -> raise "No Policy for nil object"
      {:error, mod} -> raise "Policy not found: #{mod}"
      {:ok, mod} -> mod
    end
  end
end
