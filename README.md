# Oppen's Pretty Printer
[![CI badge]][CI]
<!-- [![rubygems.org badge]][rubygems.org] -->

[CI badge]: https://github.com/Faveod/oppen-ruby/actions/workflows/ci.yml/badge.svg
[CI]: https://github.com/Faveod/oppen-ruby/actions/workflows/ci.yml

An implementation of the pretty printing algorithm described by
[Derek C. Oppen](https://dl.acm.org/doi/pdf/10.1145/357114.357115).

> [!WARNING]
> This is still under development.

## Difference with the orignal algorithm

We decided to diverge from Oppen's original algorithm to provide a more
idiomatic Ruby experience, in one particular aspect: exceptions/errors: we do
not raise exceptions when we overflow the margin.

The only exceptions that we raise indicate a bug in the implementation. Please
report them.

## Related projects

1. [Python implementation](https://github.com/stevej2608/oppen-pretty-printer)
as a library.
1. [rustc implementation](https://doc.rust-lang.org/nightly/nightly-rustc/rustc_ast_pretty/pp/index.html)