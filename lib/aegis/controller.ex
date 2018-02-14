defmodule Aegis.Controller do
  @moduledoc """
  Wraps controllers with Aegis authorization functionality.
  """

  @doc """
  Authorizes a resource, for a user, for a given action, and marks the
  connection as having had aegis authorization perfomed via the assignment of a
  boolean value to `aegis_auth_performed` on the connection.

  ## Examples

  ```
  defmodule Puppy do
    defstruct [id: nil, user_id: nil, hungry: false]
  end

  defmodule Puppy.Policy do
    @behaviour Aegis.Policy

    def sanction(_user, :index, _puppy), do: true
    def sanction(_user, :show, _puppy), do: false
  end
  ```

    iex> conn = %Plug.Conn{}
    iex> user = :user
    iex> resource = Puppy
    iex> action = :index
    iex> {:ok, conn} = Aegis.Controller.authorize(conn, user, resource, action)
    iex> conn.private[:aegis_auth_performed]
    true

    iex> conn = %Plug.Conn{}
    iex> user = :user
    iex> resource = Puppy
    iex> action = :show
    iex> {:error, :not_authorized} == Aegis.Controller.authorize(conn, user, resource, action)
    true
  """
  @spec authorize(Plug.Conn.t, term, term, atom) :: {:ok, Plug.Conn.t} | {:error, :not_authorized}
  def authorize(conn, user, resource, action) do
    conn = Plug.Conn.put_private(conn, :aegis_auth_performed, true)

    if Aegis.sanctioned?(user, action, resource) do
      {:ok, conn}
    else
      {:error, :not_authorized}
    end
  end

  @doc """
  Calls controller action *without* checking the connection to determine
  whether or not Aegis authorization has been performed.

  ## Examples
    <TODO>
  """
  @spec call_excluded_action(module,
  def call_excluded_action(mod, actn, conn) do
    apply(mod, actn, [conn, conn.params])
  end

  @doc """
  Calls controller action and performs a check on the connection in order to
  determine whether or not Aegis authorization has been performed.

  ## Examples
    <TODO>
  """
  #TODO: @spec call_included_action
  # @spec call_excluded_action(module, atom, Plug.Conn.t, ((Plug.Conn.t) -> term))
  def call_included_action(mod, actn, conn, user_fn) do
    user = user_fn.(conn)

    conn = Plug.Conn.register_before_send(conn, fn conn ->
      if conn.private[:aegis_auth_performed] do
        conn
      else
        raise Aegis.AuthorizationNotPerformedError
      end
    end)

    apply(mod, actn, [conn, conn.params, user])
  end

  #fetches the user from the connection (`conn`) via a calling to a passed
  #function (`user_fn`)
  #
  # Examples:
  #
  #   conn = some_conn
  #   user_fn = fn conn -> __MODULE__.Auth.Curator.current_resource(conn) end
  #   user = fetch_user(conn, .Auth.Curator.current_resource(conn)
  #   %User{}
  def fetch_user(conn, user_fn) do
    user_fn.(conn)
  end

  @doc """
  Allows another module to inherit `Aegis.Controller` methods.

  ## Options
  - `except` - list of actions to exclude from aegis authorization; defaults to an empty list
  - `user_fn` - function used to fetch user; defaults to an anonymous function that returns `nil`
    - e.g.) <MyAppWeb>.Auth.Curator.current_resource(conn)

  ## Examples:
    <TODO>
  """
  defmacro __using__(opts \\ []) do
    excluded_actions = Keyword.get(opts, :except, [])
    user_fn = Keyword.get(opts, :user_fn, fn conn -> nil end)
    # TODO(?):
    # Phoenix-specific...
    # action_fallback_handler = Keyword.get(opts, :fallback_handler, nil)

    quote do
      # TODO:
      # Phoenix-specific...
      # action_fallback FreshbooksWeb.Auth.ErrorHandler
      # maybe something like:
      # action_fallback unquote(fallback_handler)

      def action(conn, _opts) do
        conn
        |> action_name()
        |> case do
          actn when actn in unquote(excluded_actions) ->
            Aegis.Controller.call_excluded_action(__MODULE__, actn, conn)
          actn ->
            Aegis.Controller.call_included_action(__MODULE__, actn, conn, unquote(user_fn))
        end
      end

      def authorize(conn, user, resource, action) do
        Aegis.Controller.authorize(conn, user, resource, action)
      end

      def auth_scope(user, scope, action) do
        Aegis.Controller.auth_scope(user, scope, action)
      end

      defoverridable [action: 2, authorize: 4, auth_scope: 3]
    end
  end
end
