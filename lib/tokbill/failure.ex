defmodule Tokbill.Failure do
  @moduledoc false

  # A failure of the command line or of the ledger: the exit status and the one-line message.
  defexception [:code, :message]

  def new(code, message), do: %__MODULE__{code: code, message: message}
end
