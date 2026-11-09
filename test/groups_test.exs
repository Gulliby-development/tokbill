defmodule Tokbill.GroupsTest do
  use Tokbill.RowCase

  rows([
    row(["group", "model"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "a uses 2 tokens 1311 cost 0.005085\nb uses 1 tokens 5100 cost 0.000810\n", ""),
    row(["group", "tag"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "x uses 2 tokens 6400 cost 0.005860\n- uses 1 tokens 11 cost 0.000035\n", ""),
    row(["group", "day"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "2026-01-05 uses 1 tokens 1300 cost 0.005050\n2026-01-06 uses 1 tokens 5100 cost 0.000810\n- uses 1 tokens 11 cost 0.000035\n", ""),
    row(["group", "model"], "", 0, "", ""),
    row(["group", "tag"], "price a in=1 out=1\nuse a in=1000000 out=0 tag=b\nuse a in=1000000 out=0 tag=a\nuse a in=1000000 out=0 tag=c\n", 0, "a uses 1 tokens 1000000 cost 1.000000\nb uses 1 tokens 1000000 cost 1.000000\nc uses 1 tokens 1000000 cost 1.000000\n", ""),
    row(["group", "tag"], "price a in=1 out=1\nuse a in=1000000 out=0 tag=b\nuse a in=2000000 out=0 tag=a\nuse a in=1000000 out=0 tag=b\n", 0, "a uses 1 tokens 2000000 cost 2.000000\nb uses 2 tokens 2000000 cost 2.000000\n", ""),
    row(["group", "model"], "price Zed in=1 out=1\nprice alpha in=1 out=1\nuse Zed in=1 out=1\nuse alpha in=1 out=1\n", 0, "Zed uses 1 tokens 2 cost 0.000002\nalpha uses 1 tokens 2 cost 0.000002\n", ""),
    row(["group", "day"], "price a in=1 out=1\nuse a in=1 out=1 day=2026-03-01\nuse a in=1 out=1 day=2026-01-01\n", 0, "2026-01-01 uses 1 tokens 2 cost 0.000002\n2026-03-01 uses 1 tokens 2 cost 0.000002\n", ""),
    row(["group", "tag"], "price a in=1 out=1\nuse a in=5 out=5\nuse a in=5 out=5\n", 0, "- uses 2 tokens 20 cost 0.000020\n", "")
  ])
end
