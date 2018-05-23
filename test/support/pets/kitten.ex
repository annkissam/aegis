defmodule Pets.Kitten do
  defstruct ~w(id user_id hungry)a

  def init() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def new(%{id: id} = params) do
    kitten = struct!(__MODULE__, params)

    Agent.start_link(fn -> kitten end, name: {:global, {__MODULE__, id}})

    Agent.update(__MODULE__, &[kitten | &1])
  end

  def get(id) do
    Agent.get({:global, {__MODULE__, id}}, & &1)
  end

  def list() do
    Agent.get(__MODULE__, & &1)
  end
end
