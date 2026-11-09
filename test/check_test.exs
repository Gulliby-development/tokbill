defmodule Tokbill.CheckTest do
  use Tokbill.RowCase

  rows([
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 1\n", 0, "total spent 0.005895 limit 1.000000 ok\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.005895\n", 0, "total spent 0.005895 limit 0.005895 warn\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget tag:x 0.004\nbudget total 0.02\n", 3, "tag:x spent 0.005860 limit 0.004000 over\ntotal spent 0.005895 limit 0.020000 ok\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget day:2026-01-05 0.01\n", 0, "day:2026-01-05 spent 0.005050 limit 0.010000 ok\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "no budgets\n", ""),
    row(["check"], "", 0, "no budgets\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget tag:nothing 5\nbudget model:none 5\n", 0, "tag:nothing spent 0.000000 limit 5.000000 ok\nmodel:none spent 0.000000 limit 5.000000 ok\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0\n", 3, "total spent 0.005895 limit 0.000000 over\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nbudget total 0\n", 0, "total spent 0.000000 limit 0.000000 warn\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget model:a 0.005085\n", 0, "model:a spent 0.005085 limit 0.005085 warn\n", ""),
    row(["check"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\nbudget total 0.003\nbudget tag:x 1\nbudget model:b 0.0008\n", 3, "total spent 0.005895 limit 0.003000 over\ntag:x spent 0.005860 limit 1.000000 ok\nmodel:b spent 0.000810 limit 0.000800 over\n", "")
  ])
end
