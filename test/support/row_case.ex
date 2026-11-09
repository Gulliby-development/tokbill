defmodule Tokbill.RowCase do
  @moduledoc false

  import ExUnit.Assertions

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import Tokbill.RowCase
    end
  end

  # rows([row(ARGS, STDIN, STATUS, OUT, ERR), ...]): one test that runs every row through Tokbill.CLI.run/2 and compares the exit status, the
  # standard output and the standard error byte for byte.
  defmacro rows(list) do
    quote do
      test "rows" do
        Tokbill.RowCase.run_rows(unquote(list))
      end
    end
  end

  def row(args, stdin, status, out, err), do: {args, stdin, status, out, err}

  def run_rows(rows) do
    failures =
      rows
      |> Enum.with_index(1)
      |> Enum.flat_map(fn {{args, stdin, status, out, err}, number} ->
        case Tokbill.CLI.run(args, stdin) do
          {^status, ^out, ^err} -> []
          actual -> ["row #{number} #{inspect(args)} with input #{inspect(stdin)} gave #{inspect(actual)}"]
        end
      end)

    assert failures == []
  end
end
