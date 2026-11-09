defmodule Tokbill.CliTest do
  use Tokbill.RowCase

  rows([
    row([], "", 2, "", "usage: tokbill total\n       tokbill rates\n       tokbill group KEY [--top N]\n       tokbill explain N\n       tokbill check [--warn PCT]\n"),
    row(["help"], "", 0, "usage: tokbill total\n       tokbill rates\n       tokbill group KEY [--top N]\n       tokbill explain N\n       tokbill check [--warn PCT]\n", ""),
    row(["-h", "total", "--bogus"], "", 0, "usage: tokbill total\n       tokbill rates\n       tokbill group KEY [--top N]\n       tokbill explain N\n       tokbill check [--warn PCT]\n", ""),
    row(["--help"], "", 0, "usage: tokbill total\n       tokbill rates\n       tokbill group KEY [--top N]\n       tokbill explain N\n       tokbill check [--warn PCT]\n", ""),
    row(["--version"], "", 0, "tokbill 0.1.0\n", ""),
    row(["--version", "x"], "", 0, "tokbill 0.1.0\n", ""),
    row(["frob"], "", 2, "", "tokbill: unknown command frob\n"),
    row([""], "", 2, "", "tokbill: unknown command \n"),
    row(["Total"], "", 2, "", "tokbill: unknown command Total\n")
  ])
end
