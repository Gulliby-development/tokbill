defmodule Tokbill.LinesTest do
  use Tokbill.RowCase

  rows([
    row(["total"], "", 0, "uses 0\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "\n\n", 0, "uses 0\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "# a comment\n\n   # indented comment\n\t\nprice a in=1 out=1\nuse a in=10 out=0\n", 0, "uses 1\ninput 10\ncached 0\noutput 0\ncost 0.000010\n", ""),
    row(["total"], "price a in=1 out=1\r\nuse a in=10 out=0\r\n", 0, "uses 1\ninput 10\ncached 0\noutput 0\ncost 0.000010\n", ""),
    row(["total"], "price a in=1 out=1\nuse a in=10 out=0", 0, "uses 1\ninput 10\ncached 0\noutput 0\ncost 0.000010\n", ""),
    row(["total"], "price\ta\tin=1   out=1\n  use \t a  in=10\tout=0  \n", 0, "uses 1\ninput 10\ncached 0\noutput 0\ncost 0.000010\n", ""),
    row(["total"], "Price a in=1 out=1\n", 1, "", "tokbill: line 1: unknown line kind Price\n"),
    row(["total"], "# one\nsell a in=1 out=1\n", 1, "", "tokbill: line 2: unknown line kind sell\n"),
    row(["total"], "price a in=1 out=1\n\n# note\nuse\n", 1, "", "tokbill: line 4: use needs a model name\n"),
    row(["total"], "price a in=1 out=1\nprice\n", 1, "", "tokbill: line 2: price needs a model name\n")
  ])
end
