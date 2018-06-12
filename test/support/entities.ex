defmodule User do
  defstruct id: nil
end

defmodule Puppy do
  defstruct id: nil, user_id: nil, hungry: false
end

defmodule Kitten do
  defstruct id: nil, user_id: nil, hungry: false
end
