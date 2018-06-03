defmodule Aegis.PolicyFinder do
  @moduledoc """
  Behaviour that provides callback specifications for Policy-finding.
  """

  @callback call(Aegis.request_t()) :: {:ok, module()} | {:error, String.t()}
end
