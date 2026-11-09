defmodule Tokbill.ExplainTest do
  use Tokbill.RowCase

  rows([
    row(["explain", "1"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "use 1 on line 3: a\nuncached 800 x 25000 = 20000000\ncached 200 x 2500 = 500000\noutput 300 x 100000 = 30000000\nsum 50500000 -> 0.005050\n", ""),
    row(["explain", "2"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "use 2 on line 4: b\nuncached 5000 x 1500 = 7500000\ncached 0 x 1500 = 0\noutput 100 x 6000 = 600000\nsum 8100000 -> 0.000810\n", ""),
    row(["explain", "3"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 0, "use 3 on line 5: a\nuncached 10 x 25000 = 250000\ncached 0 x 2500 = 0\noutput 1 x 100000 = 100000\nsum 350000 -> 0.000035\n", ""),
    row(["explain", "4"], "price a in=2.5 out=10 cached=0.25\nprice b in=0.15 out=0.6\nuse a in=1000 out=300 cached=200 tag=x day=2026-01-05\nuse b in=5000 out=100 tag=x day=2026-01-06\nuse a in=10 out=1\n", 1, "", "tokbill: no use 4\n"),
    row(["explain", "1"], "# header\n\nprice a in=1 out=2 cached=0.5\nuse a in=3 out=4\n", 0, "use 1 on line 4: a\nuncached 3 x 10000 = 30000\ncached 0 x 5000 = 0\noutput 4 x 20000 = 80000\nsum 110000 -> 0.000011\n", ""),
    row(["explain", "1"], "price a in=0.3 out=0.3\nuse a in=1 out=1\n", 0, "use 1 on line 2: a\nuncached 1 x 3000 = 3000\ncached 0 x 3000 = 0\noutput 1 x 3000 = 3000\nsum 6000 -> 0.000001\n", ""),
    row(["explain", "1"], "price a in=1 out=1\nuse a in=0 out=0\n", 0, "use 1 on line 2: a\nuncached 0 x 10000 = 0\ncached 0 x 10000 = 0\noutput 0 x 10000 = 0\nsum 0 -> 0.000000\n", ""),
    row(["explain", "1"], "price a in=1 out=1\n", 1, "", "tokbill: no use 1\n"),
    row(["explain", "1"], "price a in=2 out=4 cached=1\nuse a in=100 out=100 cached=100\n", 0, "use 1 on line 2: a\nuncached 0 x 20000 = 0\ncached 100 x 10000 = 1000000\noutput 100 x 40000 = 4000000\nsum 5000000 -> 0.000500\n", "")
  ])
end
