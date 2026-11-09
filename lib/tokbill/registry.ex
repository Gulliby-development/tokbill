defmodule Tokbill.Registry do
  @moduledoc false

  @usage "usage: tokbill total\n       tokbill rates\n       tokbill group KEY [--top N]\n       tokbill explain N\n       tokbill check [--warn PCT]\n"

  def usage, do: @usage

  # Each command: its name, its option (nil for none), its number of positional arguments, the words after "needs" when one is missing and its
  # function: %{options: %{"--top" => "3"}, args: ["model"], input: text} -> {:ok, text} | {:verdict, status, text} | {:error, %Tokbill.Failure{}}.
  def commands do
    [
      %{name: "total", option: nil, positional: 0, needs: "", run: &Tokbill.Totals.total/1},
      %{name: "rates", option: nil, positional: 0, needs: "", run: &Tokbill.Totals.rates/1},
      %{name: "group", option: "--top", positional: 1, needs: "KEY", run: &Tokbill.Groups.run/1},
      %{name: "explain", option: nil, positional: 1, needs: "N", run: &Tokbill.Explain.run/1},
      %{name: "check", option: "--warn", positional: 0, needs: "", run: &Tokbill.Check.run/1}
    ]
  end

  # The integer range of an option's value.
  def bounds("--top"), do: {1, 999}
  def bounds("--warn"), do: {1, 100}
end
