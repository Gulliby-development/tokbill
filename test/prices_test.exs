defmodule Tokbill.PricesTest do
  use Tokbill.RowCase

  rows([
    row(["total"], "price gpt@x in=1 out=1\n", 1, "", "tokbill: line 1: bad model name gpt@x\n"),
    row(["total"], "price abcdefghijklmnopqrstuvwxyzABCD0123456789 in=1 out=1\n", 0, "uses 0\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "price abcdefghijklmnopqrstuvwxyzABCD0123456789x in=1 out=1\n", 1, "", "tokbill: line 1: bad model name abcdefghijklmnopqrstuvwxyzABCD0123456789x\n"),
    row(["total"], "price a in\n", 1, "", "tokbill: line 1: bad field in\n"),
    row(["total"], "price a in=1 colour=red\n", 1, "", "tokbill: line 1: unknown field colour\n"),
    row(["total"], "price a in=1 in=2 out=1\n", 1, "", "tokbill: line 1: field in given twice\n"),
    row(["total"], "price a in=1.23456 out=1\n", 1, "", "tokbill: line 1: bad rate 1.23456\n"),
    row(["total"], "price a in=1234567 out=1\n", 1, "", "tokbill: line 1: bad rate 1234567\n"),
    row(["total"], "price a in=123456.7890 out=1\n", 0, "uses 0\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "price a in=-1 out=1\n", 1, "", "tokbill: line 1: bad rate -1\n"),
    row(["total"], "price a in=1. out=1\n", 1, "", "tokbill: line 1: bad rate 1.\n"),
    row(["total"], "price a in= out=1\n", 1, "", "tokbill: line 1: bad rate \n"),
    row(["total"], "price a in=1\n", 1, "", "tokbill: line 1: price a needs in= and out=\n"),
    row(["total"], "price a out=1\n", 1, "", "tokbill: line 1: price a needs in= and out=\n"),
    row(["total"], "price a in=1 out=1\nprice a in=2 out=2\n", 1, "", "tokbill: line 2: price for a defined twice\n")
  ])
end
