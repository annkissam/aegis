defmodule AegisTest.PuppyController do
  use Phoenix.Controller, namespace: AegisTest
  import Plug.Conn

  use Aegis.Controller, except: [:index]

  action_fallback AegisTest.FallbackController

  def index(conn, _params) do
    text conn, "showing pup(s)"
  end

  def show(conn, %{"id" => 3}, _user) do
    text conn, "showing pup"
  end

  def show(conn, %{"id" => id}, user) do
    puppy = %Puppy{user_id: id}

    with {:ok, conn} <- authorized?(conn, user, puppy, :show) do
      text conn, "showing pup"
    end
  end

  def current_user(_conn) do
    %User{id: 1}
  end
end


defmodule AegisTest.FallbackController do
  use Phoenix.Controller, namespace: AegisTest

  def call(conn, {:error, :not_authorized}) do
    text conn, "not authorized"
  end
end
