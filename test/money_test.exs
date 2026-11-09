defmodule Tokbill.MoneyTest do
  use Tokbill.RowCase

  rows([
    row(["total"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse b in=1 out=0\n", 0, "uses 1\ninput 1\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "price a in=0.5 out=0\nuse a in=1 out=0\n", 0, "uses 1\ninput 1\ncached 0\noutput 0\ncost 0.000001\n", ""),
    row(["total"], "price a in=0.4999 out=0\nuse a in=1 out=0\n", 0, "uses 1\ninput 1\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "price a in=0.5 out=0\nuse a in=3 out=0\n", 0, "uses 1\ninput 3\ncached 0\noutput 0\ncost 0.000002\n", ""),
    row(["total"], "price a in=0.0001 out=0\nuse a in=10000 out=0\n", 0, "uses 1\ninput 10000\ncached 0\noutput 0\ncost 0.000001\n", ""),
    row(["total"], "price a in=100 out=0\nuse a in=1000000000 out=0\n", 0, "uses 1\ninput 1000000000\ncached 0\noutput 0\ncost 100000.000000\n", ""),
    row(["total"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "uses 3\ninput 6010\ncached 200\noutput 401\ncost 0.005895\n", ""),
    row(["total"], "price a in=2 out=4 cached=1\nuse a in=100 out=100 cached=100\n", 0, "uses 1\ninput 100\ncached 100\noutput 100\ncost 0.000500\n", ""),
    row(["total"], "price a in=2 out=4 cached=1\nuse a in=100 out=100 cached=40\n", 0, "uses 1\ninput 100\ncached 40\noutput 100\ncost 0.000560\n", ""),
    row(["total"], "price a in=0.5 out=0.5\nuse a in=1 out=0\nuse a in=1 out=0\n", 0, "uses 2\ninput 2\ncached 0\noutput 0\ncost 0.000002\n", ""),
    row(["total"], "price a in=1 out=1\nuse a in=0 out=0\n", 0, "uses 1\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", "")
  ])
end
