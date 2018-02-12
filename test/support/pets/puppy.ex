defmodule Pets.Puppy do
  defstruct ~w(id user_id hungry)a

  def init() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def new(%{id: id} = params) do
    puppy = struct!(__MODULE__, params)

    Agent.start_link(fn -> puppy end, name: {:global, {__MODULE__, id}})

    Agent.update(__MODULE__, &[puppy | &1])
  end

  def get(id) do
    Agent.get({:global, {__MODULE__, id}}, & &1)
  end

  def list() do
    Agent.get(__MODULE__, & &1)
  end
end
