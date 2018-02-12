defmodule Pets.Puppy do
  defstruct ~w(id user_id hungry)a

  def init() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def new(%{id: id} = params) do
    puppy = struct!(__MODULE__, params)

    Agent.start_link(fn -> puppy end, name: {:global, id})
    Agent.update(__MODULE__, & &1 ++ puppy, name: __MODULE__)
  end

  def get(id) do
    Agent.get({:via, __MODULE__, id}, & &1)
  end

  def list() do
    Agent.get(__MODULE__, & &1)
  end
end
