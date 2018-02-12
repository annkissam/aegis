# Pets.Puppy.init
# Pets.Puppy.new(%{id: 1, hungry: true})
# Pets.Puppy.new(%{id: 2, hungry: false})
defmodule Pets do
  alias Pets.{Puppy, Kiten}
  alias Pets.Policy.{PuppyPolicy}

  @pet_modules [Puppy, Kitten]

  def get(Pets.Puppy, id)  do
    case PuppyPolicy.sanction(nil, Pets.Puppy, :get, [id]) do
      true -> apply(Puppy, :get, [id])
      false -> nil
    end
  end
end
