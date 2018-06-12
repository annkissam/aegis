defmodule Aegis.ControllerTest do
  use ExUnit.Case
  import Phoenix.ConnTest
  doctest Aegis.Controller

  test "index" do
    conn =
      Plug.Test.conn(:get, "/puppies")
      |> Plug.Conn.put_private(:phoenix_action, :index)

    conn = AegisTest.PuppyController.action(conn, [])

    assert text_response(conn, 200) == "showing pup(s)"
  end

  test "show authorization passed" do
    conn =
      Plug.Test.conn(:get, "/puppies/1", %{id: 1})
      |> Plug.Conn.put_private(:phoenix_action, :show)

    conn = AegisTest.PuppyController.action(conn, [])

    assert text_response(conn, 200) == "showing pup"
  end

  test "show authorization failed" do
    conn =
      Plug.Test.conn(:get, "/puppies/2", %{id: 2})
      |> Plug.Conn.put_private(:phoenix_action, :show)

    conn = AegisTest.PuppyController.action(conn, [])

    assert text_response(conn, 200) == "not authorized"
  end

  test "show authorization not performed" do
    conn =
      Plug.Test.conn(:get, "/puppies/3", %{id: 3})
      |> Plug.Conn.put_private(:phoenix_action, :show)

    assert_raise Plug.Conn.WrapperError, fn ->
      AegisTest.PuppyController.action(conn, [])
    end
  end

  test "index (without excluded actions)" do
    conn =
      Plug.Test.conn(:get, "/puppies")
      |> Plug.Conn.put_private(:phoenix_action, :index)

    conn = AegisTest.PuppyWithoutExcludedActionsController.action(conn, [])

    assert text_response(conn, 200) == "showing pup(s)"
  end

  describe "auth_scope/3" do
    test "correctly filters collection based off scope specification in corresponding policy" do
      user = %User{id: 1}
      puppy_1 = %Puppy{id: 1, user_id: 1}
      puppy_2 = %Puppy{id: 2, user_id: 2}
      all_puppies = [puppy_1, puppy_2]

      assert [puppy_1] == AegisTest.PuppyController.auth_scope(user, all_puppies, :index)

      assert [puppy_1] ==
               AegisTest.PuppyController.auth_scope(user, all_puppies, :index, Puppy.Policy)
    end
  end
end
