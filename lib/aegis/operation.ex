defmodule Aegis.Operation do
  defstruct ~w(accessor fun args)a

  @type t :: %__MODULE__{
    accessor: term(),
    fun: term(),
    args: list(),
  }
end
