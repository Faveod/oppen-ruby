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

We also provide an API similar to
[`ruby/prettyprint`](https://github.com/ruby/prettyprint), which we call
`Wadler`, in reference to Philip Wadler's paper, [_A prettier
printer_](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf),
the basis for `prettyprint`. This can be really helpful if you decide to
transition from `ruby/prettyprint` to this gem.

`Wadler` is implemented on top of `Oppen`, and it provides more options than
`ruby/prettyprint`, notably:
1. Consistent and inconsistent breaking.
1. Explicit breaking, which is achievable in `ruby/prettyprint` with some
monkeypatching.

> [!CAUTION]
> This is still under development.

## Usage

A few examples of the API usage can be found in [examples/](examples/README.md).

## Oppen vs Wadler

`Wadler` calls `Oppen` under the hood, so it's not a separate implementation,
and it's not calling ruby's `prettyprint`.

Both implementations have their use cases:
1. Oppen gives more control over tokens sent to the printer.
1. Wadler gives a more _"functional"_ API, which is far nicer to work with.

That being said, both APIs in this gem can achieve the same results, especially
on consistent and inconsistent breaking.

## Noteworthy details

### Difference with Oppen's original algorithm

1. We took liberty to rename functions to make the API more modern and closer to
what we expect when writing Ruby code.  All correspondences with the algorithm
as described in Oppen's paper are noted in the comments of classes and methods.
1. We do not raise exceptions when we overflow the margin. The only exceptions
that we raise indicate a bug in the implementation. Please report them.

### Difference with `ruby/prettyprint`

Oppen's algorithm and `ruby/prettyprint` do not have the same starting positions
for a group's indentation. That's why you need to pay particular attention to
calls for `nest`; you might want to decrease them by `1` if you care about keeping
the same behavior.

This is what we do in our test suite to verify the correspondence of the `Wadler`
API and the `ruby/prettyprint`. We decided to shift the burden to the user because
we think that the deicision taken by `ruby/prettyprint` does not suit us.

## Related projects

1. [`ruby/prettyprint`](https://github.com/ruby/prettyprint)
1. [rustc implementation](https://doc.rust-lang.org/nightly/nightly-rustc/rustc_ast_pretty/pp/index.html)
1. [`stevej2608/oppen-pretty-printer`](https://github.com/stevej2608/oppen-pretty-printer) as a library.
