if Code.ensure_loaded?(Phoenix) do
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
      iex> {:ok, conn} = Aegis.Controller.authorized?(conn, user, resource, action)
      iex> conn.private[:aegis_auth_performed]
      true

      iex> conn = %Plug.Conn{}
      iex> user = :user
      iex> resource = Puppy
      iex> action = :show
      iex> {:error, :not_authorized} == Aegis.Controller.authorized?(conn, user, resource, action)
      true
    """
    @spec authorized?(Plug.Conn.t, term, term, atom) :: {:ok, Plug.Conn.t} | {:error, :not_authorized}
    def authorized?(conn, user, resource, action) do
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
    # @spec call_excluded_action(module,)
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
    # @spec call_included_action(module, atom, Plug.Conn.t))
    def call_included_action(mod, actn, conn, user) do
      conn = Plug.Conn.register_before_send(conn, fn conn ->
        if conn.private[:aegis_auth_performed] do
          conn
        else
          raise Aegis.AuthorizationNotPerformedError
        end
      end)

      apply(mod, actn, [conn, conn.params, user])
    end

    @doc """
    Allows another module to inherit `Aegis.Controller` methods.

    ## Options
    - `except` - list of actions to exclude from aegis authorization; defaults to an empty list

    ## Examples:

    For Phoenix applications:

    ```
    defmodule MyApp.PuppyController do
      use MyApp, :controller
      use Aegis.Controller

      def current_user(conn) do
        conn.assigns[:user]
      end
    end
    ```

    if you want to allow some actions to skip authorization, just use the
    `except` option:

    ```
    defmodule MyApp.Controller do
      use MyApp, :controller
      use Aegis.Controller, except: [:custom_action]

      def current_user(conn) do
        conn.assigns[:user]
      end
    end
    ```
    """
    defmacro __using__(opts \\ []) do
      excluded_actions = Keyword.get(opts, :except, [])

      quote do
        def action(conn, _opts) do
          conn
          |> action_name()
          |> case do
            actn when actn in unquote(excluded_actions) ->
              Aegis.Controller.call_excluded_action(__MODULE__, actn, conn)
            actn ->
              Aegis.Controller.call_included_action(__MODULE__, actn, conn, current_user(conn))
          end
        end

        def authorized?(conn, user, resource, action) do
          Aegis.Controller.authorized?(conn, user, resource, action)
        end

        def auth_scope(user, scope, action) do
          Aegis.Controller.auth_scope(user, scope, action)
        end

        def current_user(_), do: raise "`current_user/1` not defined for #{__MODULE__}"

        defoverridable [current_user: 1]
      end
    end
  end
end
