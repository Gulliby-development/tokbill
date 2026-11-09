defmodule Tokbill.OptionsTest do
  use Tokbill.RowCase

  rows([
    row(["total", "-x"], "", 2, "", "tokbill: unknown option -x\n"),
    row(["total", "extra"], "", 2, "", "tokbill: unexpected argument extra\n"),
    row(["group"], "", 2, "", "tokbill: group needs KEY\n"),
    row(["group", "year"], "", 2, "", "tokbill: bad group key year\n"),
    row(["group", "model", "--top"], "", 2, "", "tokbill: --top needs a value\n"),
    row(["group", "model", "--top", "0"], "", 2, "", "tokbill: --top needs an integer from 1 to 999\n"),
    row(["group", "model", "--top", "1000"], "", 2, "", "tokbill: --top needs an integer from 1 to 999\n"),
    row(["group", "model", "--top", "5", "--top", "6"], "", 2, "", "tokbill: --top given twice\n"),
    row(["group", "--top", "2"], "", 2, "", "tokbill: group needs KEY\n"),
    row(["explain"], "", 2, "", "tokbill: explain needs N\n"),
    row(["explain", "0"], "", 2, "", "tokbill: bad use number 0\n"),
    row(["explain", "abc"], "", 2, "", "tokbill: bad use number abc\n"),
    row(["explain", "1", "2"], "", 2, "", "tokbill: unexpected argument 2\n"),
    row(["check", "--warn", "0"], "", 2, "", "tokbill: --warn needs an integer from 1 to 100\n"),
    row(["check", "--warn", "101"], "", 2, "", "tokbill: --warn needs an integer from 1 to 100\n"),
    row(["check", "--warn", "50", "--warn", "60"], "", 2, "", "tokbill: --warn given twice\n")
  ])
end
