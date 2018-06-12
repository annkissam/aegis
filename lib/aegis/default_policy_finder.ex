defmodule Aegis.DefaultPolicyFinder do
  @moduledoc """
  Base policy-finding module.

  Finds policy module for corresponding data structure.  Policies are found via
  the following naming convention:

  The policy for a given resource should be named by appending "Policy" to the
  module name of the resource.

  E.g.) for resource `X`, the corresponding policy would be defined as
  `X.Policy`
  """

  @doc """
  Finds the policy module based off of the data structure of the provided
  argument. If a corresponding policy is not found, `:error` is returned.

  ## Examples:

  When Puppy.Policy is defined:

      iex> Aegis.PolicyFinder.call(Puppy)
      {:ok, Puppy.Policy}
      iex> Aegis.PolicyFinder.call(%Puppy{})
      {:ok, Puppy.Policy}

  When a policy is **not** defined for a structure:

      iex> Aegis.PolicyFinder.call(Kitten)
      {:error, "Elixir.Kitten.Policy"}
      iex> Aegis.PolicyFinder.call(%Kitten{})
      {:error, "Elixir.Kitten.Policy"}
      iex> Aegis.PolicyFinder.call(nil)
      {:error, nil}

  """
  @behaviour Aegis.PolicyFinder

  @impl Aegis.PolicyFinder
  def call(request), do: do_call(request)

  defp do_call(nil), do: {:error, nil}

  defp do_call({_, %{from: {source, schema}}})
       when is_binary(source) and is_atom(schema),
       do: do_call(schema)

  defp do_call({_, [%{__struct__: module} | _t]}), do: do_call(module)
  defp do_call({_, %{__struct__: module}}), do: do_call(module)
  defp do_call({_, module}) when is_atom(module), do: do_call(module)

  defp do_call(module) when is_atom(module) do
    try do
      {:ok, Module.safe_concat(module, "Policy")}
    rescue
      ArgumentError -> {:error, "#{module}.Policy"}
    end
  end

  defp do_call(args), do: {:error, args}
end
