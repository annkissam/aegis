defmodule User do
  defstruct [id: nil]
end

defmodule Puppy do
  defstruct [id: nil, user_id: nil, hungry: false]
end

defmodule Puppy.Policy do
  @behaviour Aegis.Policy

  def sanction(%User{id: id}, :show, %Puppy{user_id: id}), do: true
  def sanction(_user, :show, _puppy), do: false

  def sanction(_user, :index, _puppy), do: true

  def scope(_user, _scope, :index), do: :index_scope
  def scope(_user, _scope, :show), do: :show_scope
end

defmodule AegisTest.PuppyController do
  use Phoenix.Controller, namespace: AegisTest
  import Plug.Conn

  use Aegis.Controller, except: [:index]

  action_fallback AegisTest.FallbackController

  def index(conn, _params) do
    text conn, "showing pup(s)"
  end

  def show(conn, %{"id" => 3}, user) do
    puppy = %Puppy{user_id: 1}

    text conn, "showing pup"
  end

  def show(conn, %{"id" => id}, user) do
    puppy = %Puppy{user_id: id}

    with {:ok, conn} <- authorized?(conn, user, puppy, :show) do
      text conn, "showing pup"
    end
  end

  def current_user(conn) do
    %User{id: 1}
  end
end

defmodule Kitten do
  defstruct [id: nil, user_id: nil, hungry: false]
end

defmodule AegisTest.FallbackController do
  use Phoenix.Controller, namespace: AegisTest
  import Plug.Conn

  def call(conn, {:error, :not_authorized}) do
    text conn, "not authorized"
  end
end

ExUnit.start()
