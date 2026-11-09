defmodule Tokbill do
  @moduledoc false

  # The escript entry point: standard input is read only when the command line names a command.
  def main(args) do
    input = if Tokbill.CLI.reads_stdin?(args), do: read_stdin(), else: ""
    {status, out, err} = Tokbill.CLI.run(args, input)
    IO.binwrite(:stdio, out)
    IO.binwrite(:stderr, err)
    System.halt(status)
  end

  defp read_stdin do
    case IO.binread(:stdio, :eof) do
      data when is_binary(data) -> data
      _ -> ""
    end
  end
end
