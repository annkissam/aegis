defmodule Aegis.ControllerTest do
  use ExUnit.Case
  import Phoenix.ConnTest
  doctest Aegis.Controller

  test "index" do
    conn = Plug.Test.conn(:get, "/puppies")
           |> Plug.Conn.put_private(:phoenix_action, :index)

    conn = AegisTest.PuppyController.action(conn, [])

    assert text_response(conn, 200) == "showing pup(s)"
  end

  test "show authorization passed" do
    conn = Plug.Test.conn(:get, "/puppies/1", %{id: 1})
           |> Plug.Conn.put_private(:phoenix_action, :show)

    conn = AegisTest.PuppyController.action(conn, [])

    assert text_response(conn, 200) == "showing pup"
  end

  test "show authorization failed" do
    conn = Plug.Test.conn(:get, "/puppies/2", %{id: 2})
           |> Plug.Conn.put_private(:phoenix_action, :show)

    conn = AegisTest.PuppyController.action(conn, [])

    assert text_response(conn, 200) == "not authorized"
  end

  test "show authorization not performed" do
    conn = Plug.Test.conn(:get, "/puppies/3", %{id: 3})
           |> Plug.Conn.put_private(:phoenix_action, :show)

    assert_raise Plug.Conn.WrapperError, fn ->
      AegisTest.PuppyController.action(conn, [])
    end
  end

  test "index (without excluded actions)" do
    conn = Plug.Test.conn(:get, "/puppies")
           |> Plug.Conn.put_private(:phoenix_action, :index)

    conn = AegisTest.PuppyWithoutExcludedActionsController.action(conn, [])

    assert text_response(conn, 200) == "showing pup(s)"
  end
end
