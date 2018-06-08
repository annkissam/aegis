if Code.ensure_loaded?(Phoenix) do
  defmodule Aegis.AuthorizationNotPerformedError do
    @moduledoc """
    Raised when authorization has not been implemented by the end of the Plug
    pipeline.
    """
    defexception [conn: nil, message: "Not Authorized"]
  end

  defimpl Plug.Exception, for: Aegis.AuthorizationNotPerformedError do
    def status(_exception), do: 403
  end
end
