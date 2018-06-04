defmodule Aegis.PolicyFinder do
  @moduledoc """
  Behaviour that provides callback specifications for Policy-finding.
  """

  @callback call(Aegis.Accessor.t()) :: {:ok, module()} | {:error, String.t()}
end
