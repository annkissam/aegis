defmodule AegisTest.PuppyController do
  use Phoenix.Controller, namespace: AegisTest
  import Plug.Conn

  use Aegis.Controller, except: [:index]

  action_fallback(AegisTest.FallbackController)

  def index(conn, _params) do
    text(conn, "showing pup(s)")
  end

  def show(conn, %{"id" => 3}, _user) do
    text(conn, "showing pup")
  end

  def show(conn, %{"id" => id}, user) do
    puppy = %Puppy{user_id: id}

    with {:ok, conn} <- authorized?(conn, user, puppy, action: :show) do
      text(conn, "showing pup")
    end
  end

  def current_user(_conn) do
    %User{id: 1}
  end
end

defmodule AegisTest.PuppyWithoutExcludedActionsController do
  use Phoenix.Controller, namespace: AegisTest
  import Plug.Conn

  use Aegis.Controller

  action_fallback(AegisTest.FallbackController)

  def index(conn, _params, user) do
    with {:ok, conn} <- authorized?(conn, user, Puppy, action: :index) do
      text(conn, "showing pup(s)")
    end
  end

  def current_user(_conn) do
    %User{id: 1}
  end
end

defmodule AegisTest.FallbackController do
  use Phoenix.Controller, namespace: AegisTest

  def call(_conn, {:error, conn}) do
    text(conn, "not authorized")
  end
end
