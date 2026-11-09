defmodule Tokbill.RatesTest do
  use Tokbill.RowCase

  rows([
    row(["rates"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\n", 0, "a in 2.5 out 10 cached 0.25\nb in 0.15 out 0.6 cached 0.15\n", ""),
    row(["rates"], "price b in=3.0000 out=0\n", 0, "b in 3 out 0 cached 3\n", ""),
    row(["rates"], "price m in=0.0001 out=0.0010 cached=0.0100\n", 0, "m in 0.0001 out 0.001 cached 0.01\n", ""),
    row(["rates"], "price Zed in=1 out=1\nprice alpha in=1 out=1\nprice a1 in=1 out=1\nprice A in=1 out=1\n", 0, "A in 1 out 1 cached 1\nZed in 1 out 1 cached 1\na1 in 1 out 1 cached 1\nalpha in 1 out 1 cached 1\n", ""),
    row(["rates"], "price a in=123456.9999 out=100000 cached=0\n", 0, "a in 123456.9999 out 100000 cached 0\n", ""),
    row(["rates"], "", 0, "", ""),
    row(["rates"], "price a in=0 out=0\n", 0, "a in 0 out 0 cached 0\n", ""),
    row(["rates"], "price a in=2.50 out=0.075 cached=2.5\n", 0, "a in 2.5 out 0.075 cached 2.5\n", "")
  ])
end
