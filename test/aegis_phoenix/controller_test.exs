defmodule Aegis.Phoenix.ControllerTest do
  use ExUnit.Case
  import Phoenix.ConnTest
  doctest Aegis.Phoenix.Controller

  defmodule PuppyController do
    use Phoenix.Controller, namespace: Aegis.Phoenix.ControllerTest
    import Plug.Conn

    use Aegis.Phoenix.Controller, except: [:index]

    action_fallback Aegis.Phoenix.ControllerTest.FallbackController

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

  defmodule PuppyWithoutExcludedActionsController do
    use Phoenix.Controller, namespace: Aegis.Phoenix.ControllerTest
    import Plug.Conn

    use Aegis.Phoenix.Controller

    action_fallback Aegis.Phoenix.ControllerTest.FallbackController

    def index(conn, _params, user) do
      with {:ok, conn} <- authorized?(conn, user, Puppy, :index) do
        text conn, "showing pup(s)"
      end
    end

    def current_user(_conn) do
      %User{id: 1}
    end
  end

  defmodule FallbackController do
    use Phoenix.Controller, namespace: Aegis.Phoenix.ControllerTest

    def call(conn, {:error, :not_authorized}) do
      text conn, "not authorized"
    end
  end

  test "index" do
    conn = Plug.Test.conn(:get, "/puppies")
           |> Plug.Conn.put_private(:phoenix_action, :index)

    conn = PuppyController.action(conn, [])

    assert text_response(conn, 200) == "showing pup(s)"
  end

  test "show authorization passed" do
    conn = Plug.Test.conn(:get, "/puppies/1", %{id: 1})
           |> Plug.Conn.put_private(:phoenix_action, :show)

    conn = PuppyController.action(conn, [])

    assert text_response(conn, 200) == "showing pup"
  end

  test "show authorization failed" do
    conn = Plug.Test.conn(:get, "/puppies/2", %{id: 2})
           |> Plug.Conn.put_private(:phoenix_action, :show)

    conn = PuppyController.action(conn, [])

    assert text_response(conn, 200) == "not authorized"
  end

  test "show authorization not performed" do
    conn = Plug.Test.conn(:get, "/puppies/3", %{id: 3})
           |> Plug.Conn.put_private(:phoenix_action, :show)

    assert_raise Plug.Conn.WrapperError, fn ->
      PuppyController.action(conn, [])
    end
  end

  test "index (without excluded actions)" do
    conn = Plug.Test.conn(:get, "/puppies")
           |> Plug.Conn.put_private(:phoenix_action, :index)

    conn = PuppyWithoutExcludedActionsController.action(conn, [])

    assert text_response(conn, 200) == "showing pup(s)"
  end

  describe "auth_scope/3" do
    test "correctly filters collection based off scope specification in corresponding policy" do
      user = %User{id: 1}
      puppy_1 = %Puppy{id: 1, user_id: 1}
      puppy_2 = %Puppy{id: 2, user_id: 2}
      all_puppies = [puppy_1, puppy_2]

      assert [puppy_1] == PuppyController.auth_scope(user, all_puppies, :index)
      assert [puppy_1] == PuppyController.auth_scope(user, all_puppies, :index, Puppy.Policy)
    end
  end
end

