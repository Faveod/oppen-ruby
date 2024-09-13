# Oppen's Pretty Printer
[![CI badge]][CI]
[![Docs latest badge]][Docs latest]
[![rubygems.org badge]][rubygems.org]

[CI badge]: https://github.com/Faveod/oppen-ruby/actions/workflows/test.yml/badge.svg
[CI]: https://github.com/Faveod/oppen-ruby/actions/workflows/test.yml
[Docs latest badge]: https://github.com/Faveod/oppen-ruby/actions/workflows/docs.yml/badge.svg
[Docs latest]: https://faveod.github.io/oppen-ruby/
[rubygems.org badge]: https://img.shields.io/gem/v/oppen?label=rubygems.org
[rubygems.org]: https://rubygems.org/gems/oppen

An implementation of the pretty printing algorithm described by
[Derek C. Oppen](https://dl.acm.org/doi/pdf/10.1145/357114.357115).

> [!WARNING]
> This is still under development.

## Difference with the original algorithm

We decided to diverge from Oppen's original algorithm to provide a more
idiomatic Ruby experience, in one particular aspect: exceptions/errors: we do
not raise exceptions when we overflow the margin.

The only exceptions that we raise indicate a bug in the implementation. Please
report them.

## Difference with ruby's PrettyPrint library

Our implementation had as a goal to mimic the usage of ruby's PrettyPrint library, we decided to
inspire some tests of our test suite from ruby's PrettyPrint library test suite.
We however had to slightly modify some tests due to the fact that Oppen's algorithm and
ruby's PrettyPrint do not have the same starting positions for a group's indentation.

## Related projects

1. [Python implementation](https://github.com/stevej2608/oppen-pretty-printer)
as a library.
1. [rustc implementation](https://doc.rust-lang.org/nightly/nightly-rustc/rustc_ast_pretty/pp/index.html)
1. [ruby PrettyPrint library](https://github.com/ruby/prettyprint/tree/master)
