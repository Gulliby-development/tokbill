defmodule Tokbill.UsesTest do
  use Tokbill.RowCase

  rows([
    row(["total"], "price a in=1 out=1\nuse a in=1.5 out=1\n", 1, "", "tokbill: line 2: bad count 1.5\n"),
    row(["total"], "price a in=1 out=1\nuse a in=12345678901 out=1\n", 1, "", "tokbill: line 2: bad count 12345678901\n"),
    row(["total"], "price a in=1 out=1\nuse a in=1000000001 out=1\n", 1, "", "tokbill: line 2: bad count 1000000001\n"),
    row(["total"], "price a in=1 out=1\nuse a in=1000000000 out=0\n", 0, "uses 1\ninput 1000000000\ncached 0\noutput 0\ncost 1000.000000\n", ""),
    row(["total"], "price a in=1 out=1\nuse a in=1 out=\n", 1, "", "tokbill: line 2: bad count \n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 cached=6\n", 1, "", "tokbill: line 2: cached tokens exceed input tokens\n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 cached=5\n", 0, "uses 1\ninput 5\ncached 5\noutput 1\ncost 0.000006\n", ""),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 tag=abcdefghijklmnopqrstu\n", 1, "", "tokbill: line 2: bad tag abcdefghijklmnopqrstu\n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 tag=abcdefghijklmnopqrst\n", 0, "uses 1\ninput 5\ncached 0\noutput 1\ncost 0.000006\n", ""),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 day=2026-02-30\n", 1, "", "tokbill: line 2: bad day 2026-02-30\n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 day=2026-13-01\n", 1, "", "tokbill: line 2: bad day 2026-13-01\n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 day=1969-12-31\n", 1, "", "tokbill: line 2: bad day 1969-12-31\n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 day=2026-1-1\n", 1, "", "tokbill: line 2: bad day 2026-1-1\n"),
    row(["total"], "price a in=1 out=1\nuse a in=5 out=1 day=2024-02-29\n", 0, "uses 1\ninput 5\ncached 0\noutput 1\ncost 0.000006\n", ""),
    row(["total"], "price a in=1 out=1\nuse a in=5\n", 1, "", "tokbill: line 2: use a needs in= and out=\n"),
    row(["total"], "price a in=1 out=1\nuse b in=5 out=1\nuse c in=5 out=1\n", 1, "", "tokbill: line 2: no price for b\n"),
    row(["total"], "use a in=5 out=1\nprice a in=1 out=1\n", 0, "uses 1\ninput 5\ncached 0\noutput 1\ncost 0.000006\n", "")
  ])
end
