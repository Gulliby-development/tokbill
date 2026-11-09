<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# tokbill

[![CI](https://github.com/Gulliby-development/tokbill/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/tokbill/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Tokbill prices a plain-text log of model calls against integer-valued rates. It reports token usage and cost by model, tag, or day, explains one call's arithmetic, and checks budgets for CI. It is intended for teams building and operating LLM clients and evaluation harnesses who want deterministic answers before the monthly bill arrives.

## Requirements and build

Install Elixir 1.15 or newer and its compatible Erlang/OTP runtime. Tokbill has no package dependencies and runs on Windows, macOS, and Linux.

Build the escript from the repository root:

```text
mix escript.build
```

Then provide a ledger on standard input:

```text
./tokbill check < usage.ledger
```

The escript is built for the host platform. On Windows, run it with `escript tokbill` (for example, `Get-Content -Raw usage.ledger | escript tokbill check`) or use the invocation form provided by your Erlang installation. The `printf` commands below are illustrative POSIX shell input examples only. Unix tools such as `printf` are not Tokbill runtime dependencies.

## Commands

```text
usage: tokbill total
       tokbill rates
       tokbill group KEY [--top N]
       tokbill explain N
       tokbill check [--warn PCT]
```

The first word `help`, `-h`, or `--help` prints that usage; `--version` prints `tokbill 0.1.0`. Both ignore later words. A registered command reads all standard input as one ledger. Help, version, missing commands, and unknown commands do not read it. With no command, usage goes to standard error. Command names are case-sensitive.

### Examples

Each example supplies this three-line ledger inline. For `explain`, the call is on ledger line 2. These `printf` pipelines are POSIX shell examples; on Windows, save the three ledger lines to `usage.ledger` and pipe the file to `escript tokbill COMMAND` instead.

`total`:

```sh
printf '%s\n' 'price atlas in=2.5 out=10 cached=0.25' 'use atlas in=1000 out=300 cached=200 tag=chat day=2026-01-05' 'budget total 0.01' | ./tokbill total
```

```text
uses 1
input 1000
cached 200
output 300
cost 0.005050
```

`rates`:

```sh
printf '%s\n' 'price atlas in=2.5 out=10 cached=0.25' 'use atlas in=1000 out=300 cached=200 tag=chat day=2026-01-05' 'budget total 0.01' | ./tokbill rates
```

```text
atlas in 2.5 out 10 cached 0.25
```

`group --top 1 model` (the option may also follow the key):

```sh
printf '%s\n' 'price atlas in=2.5 out=10 cached=0.25' 'use atlas in=1000 out=300 cached=200 tag=chat day=2026-01-05' 'budget total 0.01' | ./tokbill group --top 1 model
```

```text
atlas uses 1 tokens 1300 cost 0.005050
```

`explain 1`:

```sh
printf '%s\n' 'price atlas in=2.5 out=10 cached=0.25' 'use atlas in=1000 out=300 cached=200 tag=chat day=2026-01-05' 'budget total 0.01' | ./tokbill explain 1
```

```text
use 1 on line 2: atlas
uncached 800 x 25000 = 20000000
cached 200 x 2500 = 500000
output 300 x 100000 = 30000000
sum 50500000 -> 0.005050
```

`check`:

```sh
printf '%s\n' 'price atlas in=2.5 out=10 cached=0.25' 'use atlas in=1000 out=300 cached=200 tag=chat day=2026-01-05' 'budget total 0.01' | ./tokbill check
```

```text
total spent 0.005050 limit 0.010000 ok
```

Every successful command writes its report to standard output, leaves standard error empty, and ends each output line with LF. A command-line failure writes no standard output and one `tokbill: MESSAGE` line to standard error. A ledger failure has the same form. Exit status 0 means success; status 1 means a ledger-dependent failure (including an unavailable call number); status 2 means command-line error; status 3 is an over-budget `check` verdict and still includes its report on standard output.

### Command behavior

- `total` prints five lines: call count, total input tokens (including cached input), cached tokens, output tokens, and total cost. With no calls it prints zero for each value and `cost 0.000000`.
- `rates` prints one line per price, sorted by model name in byte order, with normalized rates (no unnecessary trailing zeroes). It prints nothing when there are no prices.
- `group KEY` accepts `model`, `tag`, or `day`. It prints each group as `NAME uses U tokens T cost USD`, ordered by descending summed, individually rounded call cost, then name in byte order. Token totals include input plus output. Missing tag/day values are shown as `-`; no calls produce no output. `--top N` keeps the first N groups and, only when groups were omitted, adds `others K cost USD` with their count and summed cost.
- `explain N` numbers calls in use-line order, not physical line order. It prints the original ledger line and the uncached, cached, and output count/rate/product calculations, followed by the raw product sum and rounded USD cost. A valid number with no corresponding call reports `tokbill: no use N` and exits 1, after validating the complete ledger.
- `check` reports budgets in ledger order as `SCOPE spent USD limit USD STATUS`. Total, model, tag, and day scopes sum the rounded costs of matching calls. A scope with no matching calls spends zero. `--warn PCT` sets the warning percentage (1–100; default 80): status is `over` if spending exceeds the limit, otherwise `warn` if spending times 100 is at least PCT times the limit, otherwise `ok`. Over takes precedence over warn. A zero limit and zero spend is `warn`. With no budgets it prints `no budgets`; over-budget reports exit 3, all others exit 0.

## Ledger format

The ledger is plain text, read as bytes. Lines are separated by LF; a CR immediately before LF is removed. A final nonempty unterminated line counts. Words are separated by one or more spaces or tabs, with surrounding blanks ignored. Empty lines and lines whose first word starts with `#` are ignored. Remaining lines begin with the case-sensitive kind `price`, `use`, or `budget`. Error line numbers count every physical line, including ignored lines, and the first error in ledger order is reported.

Models contain 1–40 characters from `A-Z a-z 0-9 . _ : / -`. Fields are whitespace-separated `KEY=VALUE` words, split at the first equals sign. For each field, checks occur in this order: equals sign present, key known, key not repeated on that line, then value valid. Required fields and later checks follow the field scan. The first bad field ends parsing.

- `price MODEL in=RATE out=RATE [cached=RATE]`: rates are required; cached rate defaults to the input rate. A repeated model price is an error.
- `use MODEL in=N out=N [cached=N] [tag=TAG] [day=YYYY-MM-DD]`: input and output counts are required; cached count defaults to zero and cannot exceed input. Counts are decimal digits, at most 10 digits and at most 1,000,000,000. Tags contain 1–20 lowercase letters, digits, underscores, or hyphens. Days must be real dates from 1970-01-01 through 2999-12-31 in four-digit-year, two-digit-month, two-digit-day form; omitted tag and day display as `-`.
- `budget SCOPE LIMIT`: exactly two words follow the kind. Scope is `total`, `model:NAME` (valid model), `tag:NAME` (valid tag), or `day:DATE` (valid date). Scope is checked before limit; a duplicate scope is an error.

A model used in a call must have a price somewhere in the ledger. This check is deferred until all lines have been read, and the first unpriced call in use-line order is reported. Thus a later price can satisfy an earlier use, but a syntax or validation error on any line takes precedence over deferred missing-price errors.

### Accepted values and error messages

Rates are dollars per million tokens: 1–6 digits, optionally followed by a decimal point and 1–4 digits. Limits are dollars: 1–9 digits, optionally followed by a decimal point and 1–6 digits. Neither accepts signs, exponent notation, a missing whole-number part, or a decimal point without fractional digits. Counts and option values use ASCII decimal digits.

Ledger errors exit 1 and are prefixed `line N: `. Their exact message forms are:

- Unknown kind: `unknown line kind WORD`.
- Missing model: `price needs a model name` or `use needs a model name`; invalid model: `bad model name WORD`.
- Field errors: `bad field WORD`, `unknown field KEY`, `field KEY given twice`, `bad rate TEXT`, `bad count TEXT`, `bad tag TEXT`, or `bad day TEXT`.
- Missing required price/use rates: `price MODEL needs in= and out=` or `use MODEL needs in= and out=`; cached count too large: `cached tokens exceed input tokens`.
- Repeated definitions: `price for MODEL defined twice`, `budget for SCOPE defined twice`.
- Invalid budget: `budget needs SCOPE and LIMIT`, `unexpected WORD`, `bad scope TEXT`, or `bad limit TEXT`.
- Deferred use validation: `no price for MODEL`.

Command-line words are scanned from left to right before the ledger is parsed. A word beginning with `-` and longer than one character is an option; all other words, including `-` and the empty word, are positional. The first applicable error wins during scanning: unsupported option (`unknown option WORD`), repeated option (`WORD given twice`), missing/empty option value (`WORD needs a value`), or excess positional word (`unexpected argument WORD`). An option consumes the next word even if it begins with a hyphen. Options may appear before or after positional arguments, so both `group --top 1 model` and `group model --top 1` are accepted. Once scanning ends, validation order is missing positional (`group needs KEY` or `explain needs N`), invalid option value, then invalid group key or use number. Option errors are `--top needs an integer from 1 to 999` and `--warn needs an integer from 1 to 100`; values must have 1–5 ASCII digits. `explain N` requires N to have 1–5 ASCII digits and a value from 1 to 99999. Other final errors are `bad group key TEXT` and `bad use number TEXT`. Missing command prints usage to standard error; unknown command is `unknown command WORD`. All command-line errors exit 2.

## Exact integer pricing

Rates are stored in units of 1/10,000 of a dollar per million tokens (so rate `2.5` is 25,000 units). For a call, Tokbill multiplies uncached input tokens by the input rate, cached input tokens by the cached rate, and output tokens by the output rate. The products sum to S. Dividing S by 10,000 gives micro-dollars; each call cost is rounded half up using `(S + 5000) div 10000`. Each call is rounded separately before totals, groups, or budgets sum costs. No floating-point arithmetic is used. USD reports always have six fractional digits.

## Development

Run the project's formatting, compilation, and acceptance checks from the repository root:

```text
mix format
mix format --check-formatted
mix compile --warnings-as-errors
mix test
```

See the [MIT License](LICENSE) for copying and distribution terms.

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R85).
