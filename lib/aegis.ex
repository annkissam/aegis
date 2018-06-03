defmodule Aegis do
  @moduledoc """
  Lightweight, flexible authorization.

  ## Configuration

  TODO: add documentation for configuration options

    * `policy_finder`
  """

  @type accessor_t :: Process.t() | any()

  @type accessible_t :: Tuple.t() | fun()

  @doc """
  Returns `true` if an accessor is authorized to access a resource or perform an
  operation. The responsibility for determining whether or not a given resource
  or operation is accessible to an accessor is delegated to a policy module.

  The policy module for any given authorization check can be explicitely
  specified, or, if no policy is provided, an attempt is made to locate
  a policy for the accessible via a search based on conventional policy naming.

  ## Example

  As an example, suppose your library defines the following resources:

      defmodule User do
        defstruct [id: nil]
      end

      defmodule Puppy do
        defstruct [id: nil, user_id: nil, hungry: false]
      end

      defmodule Kitten do
        defstruct [id: nil, user_id: nil, hungry: false]
      end

  If you want to define access to the `Puppy` resource, the first step is to define a
  policy for the puppy resource. Maybe something like:

      defmodule Puppy.Policy do
        @behaviour Aegis.Policy

        def authorized?(_user, {:index, _puppy}), do: true
        def authorized?(%User{id: id}, {:show, %Puppy{user_id: id}}), do: true
        def authorized?(_user, {:show, _puppy}), do: false

      end

  For the purposes of our example, the puppy policy definition above specifies that:
    * any user has access to the "index" page of puppy data, and
    * only users who own particular puppies (i.e. the puppy's `user_id` matches the users `id`) will be able to access the data corresponding to their "show" page

  With this, we can check check for authorization of puppies via making calls to
  `Aegis.authorized?/3` with the appropriate arguments:

      iex> Aegis.authorized?(%User{id: 1}, {:index, Puppy}, Puppy.Policy)
      true
      iex> Aegis.authorized?(%User{id: 2}, {:index, Puppy}, Puppy.Policy)
      true
      iex> Aegis.authorized?(%User{id: 1}, {:show, %Puppy{user_id: 1}}, Puppy.Policy)
      true
      iex> Aegis.authorized?(%User{id: 1}, {:show, %Puppy{user_id: 2}}, Puppy.Policy)
      false

  At this point, you may have noticed that we haven't defined a policy
  definition for our `Kitten` resource. As such, if we attempt to check for
  authorization, we will receive an error that lets us know that a
  corresponding policy wasn't found via a lookup based off policy naming
  convention:

      iex> Aegis.authorized?(:user, {:index, Kitten})
      ** (RuntimeError) Policy not found: Elixir.Kitten.Policy

  If we really don't want to define a policy for the `Kitten` resource, one way
  we can get around this error is to explicitely pass the policy via which the
  kitten resource should be authorized. For the purpose of this example, we'll
  just specify that the kitten "index" page can refer to the `Puppy.Policy`:

      iex> Aegis.authorized?(:user, {:index, Kitten}, Puppy.Policy)
      true

  """
  @spec authorized?(__MODULE__.accessor_t(), __MODULE__.accessible_t(), module()) :: boolean
  def authorized?(accessor, accessible, policy \\ nil)
  def authorized?(accessor, accessible, nil) do
    authorized?(accessor, accessible, fetch_policy_module(accessible))
  end
  def authorized?(accessor, accessible, policy) do
    apply(policy, :authorized?, [accessor, accessible])
  end

  @default_finder __MODULE__.DefaultPolicyFinder

  @policy_finder Application.get_env(:aegis, :policy_finder, @default_finder)

  # def __policy_finder__, do: @policy_finder

  defp fetch_policy_module(arg) do
    case @policy_finder.call(arg) do
      {:error, nil} -> raise "No Policy for nil object"
      {:error, mod} -> raise "Policy not found: #{mod}"
      {:ok, mod} -> mod
    end
  end
end
