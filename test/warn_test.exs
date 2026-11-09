defmodule Tokbill.WarnTest do
  use Tokbill.RowCase

  rows([
    row(["check", "--warn", "50"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.01\n", 0, "total spent 0.005895 limit 0.010000 warn\n", ""),
    row(["check", "--warn", "60"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.01\n", 0, "total spent 0.005895 limit 0.010000 ok\n", ""),
    row(["check", "--warn", "100"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.005895\n", 0, "total spent 0.005895 limit 0.005895 warn\n", ""),
    row(["check", "--warn", "100"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.005896\n", 0, "total spent 0.005895 limit 0.005896 ok\n", ""),
    row(["check", "--warn", "1"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 100\n", 0, "total spent 0.005895 limit 100.000000 ok\n", ""),
    row(["check", "--warn", "80"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.007368\n", 0, "total spent 0.005895 limit 0.007368 warn\n", ""),
    row(["check", "--warn", "80"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.007369\n", 0, "total spent 0.005895 limit 0.007369 ok\n", ""),
    row(["check", "--warn", "99"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nbudget total 0\n", 0, "total spent 0.000000 limit 0.000000 warn\n", "")
  ])
end
