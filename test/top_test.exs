defmodule Tokbill.TopTest do
  use Tokbill.RowCase

  rows([
    row(["group", "tag", "--top", "1"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "x uses 2 tokens 6400 cost 0.005860\nothers 1 cost 0.000035\n", ""),
    row(["group", "tag", "--top", "2"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "x uses 2 tokens 6400 cost 0.005860\n- uses 1 tokens 11 cost 0.000035\n", ""),
    row(["group", "tag", "--top", "999"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "x uses 2 tokens 6400 cost 0.005860\n- uses 1 tokens 11 cost 0.000035\n", ""),
    row(["group", "model", "--top", "1"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "a uses 2 tokens 1311 cost 0.005085\nothers 1 cost 0.000810\n", ""),
    row(["group", "--top", "1", "day"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "2026-01-05 uses 1 tokens 1300 cost 0.005050\nothers 2 cost 0.000845\n", ""),
    row(["group", "day", "--top", "1"], "", 0, "", ""),
    row(["group", "tag", "--top", "1"], "price a in=1 out=1\nuse a in=1000000 out=0 tag=a\nuse a in=1000000 out=0 tag=b\nuse a in=1000000 out=0 tag=c\nuse a in=1000000 out=0 tag=d\n", 0, "a uses 1 tokens 1000000 cost 1.000000\nothers 3 cost 3.000000\n", "")
  ])
end
