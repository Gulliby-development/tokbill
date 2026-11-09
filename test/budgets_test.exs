defmodule Tokbill.BudgetsTest do
  use Tokbill.RowCase

  rows([
    row(["total"], "budget total\n", 1, "", "tokbill: line 1: budget needs SCOPE and LIMIT\n"),
    row(["total"], "budget\n", 1, "", "tokbill: line 1: budget needs SCOPE and LIMIT\n"),
    row(["total"], "budget total 1 2\n", 1, "", "tokbill: line 1: unexpected 2\n"),
    row(["total"], "budget week 1\n", 1, "", "tokbill: line 1: bad scope week\n"),
    row(["total"], "budget tag:Chat 1\n", 1, "", "tokbill: line 1: bad scope tag:Chat\n"),
    row(["total"], "budget day:2026-02-30 1\n", 1, "", "tokbill: line 1: bad scope day:2026-02-30\n"),
    row(["total"], "budget total 1.1234567\n", 1, "", "tokbill: line 1: bad limit 1.1234567\n"),
    row(["total"], "budget total -1\n", 1, "", "tokbill: line 1: bad limit -1\n"),
    row(["total"], "budget total 1000000000\n", 1, "", "tokbill: line 1: bad limit 1000000000\n"),
    row(["total"], "budget total 999999999.999999\n", 0, "uses 0\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", ""),
    row(["total"], "budget total 1\nbudget total 2\n", 1, "", "tokbill: line 2: budget for total defined twice\n"),
    row(["total"], "budget total 1\nbudget tag:a 2\nbudget model:x 3\nbudget day:2026-01-05 4\n", 0, "uses 0\ninput 0\ncached 0\noutput 0\ncost 0.000000\n", "")
  ])
end
