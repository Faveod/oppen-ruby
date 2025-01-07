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
1. [Consistent](examples/wadler_group/consistent.rb) and [inconsistent](examples/wadler_group/inconsistent.rb) breaking.
1. [Explicit breaking](examples/wadler_break_and_breakable/break.rb), which is achievable in `ruby/prettyprint` with some monkeypatching.
1. [Trimming of trailing whitespaces](examples/oppen_and_wadler_customization/whitespace.rb).
1. [Display a `String` on line break](examples/wadler_break_and_breakable/line_continuation.rb).
1. A bunch of helper methods to simplify common patterns like [surrounding](examples/wadler_utils/surround.rb) or
[separating](examples/wadler_utils/surround.rb) tokens.

## Oppen vs Wadler

`Wadler` calls `Oppen` under the hood, so it's not a separate implementation,
and it's not calling ruby's `prettyprint`.

Both implementations have their use cases:
- Oppen gives more control over tokens sent to the printer.
- Wadler gives a more _"functional"_ API, which is far nicer to work with.

That being said, both APIs in this gem can achieve the same results, especially
on consistent and inconsistent breaking.

## Oppen's API Example

```ruby
tokens = [
  Oppen.begin_inconsistent,
  Oppen.string('Hello'),
  Oppen.break(', '),
  Oppen.string('World!'),
  Oppen.line_break,
  Oppen.string('How are you doing?'),
  Oppen.end,
  Oppen.eof,
]

puts Oppen.print(tokens:)
# Hello, World!
#   How are you doing?
```

## Wadler's API Example

```ruby
out = Oppen::Wadler.new(width: 20)

out.group(indent: 2) {
  out.group {
    out.text('def').breakable.text('foo')
  }
  out.parens_break_none {
    out.separate(%w[bar baz bat qux], ',', break_type: :inconsistent) { |param|
      out.text(param)
    }
  }
}
out.group(indent: 2) {
  out
    .break
    .nest(indent: 2) {
      out
        .text('puts')
        .breakable(line_continuation: ' \\')
        .text('42')
  }
}
out.break.text('end')

puts out.output
# def foo(bar, baz,
#   bat, qux)
#   puts \
#     42
# end
```

## More Examples

An easy way to add colors to the output on the terminal is wrap `oppen` and expose your own vocabulary:

```ruby
require 'colored'
class ColoredTty
  KW_PALETTE = { Hello: :red, World: :green }.freeze
  def initialize(...) = @out = Oppen::Wadler.new(...)
  def breakable(...) = @out.breakable(...) && self
  def keyword(value, width: value.length) = @out.text(value.send(KW_PALETTE[value.to_sym] || :white), width:) && self
  def output = @out.output
  def text(...) = @out.text(...) && self
end

out = ColoredTty.new(width: 12)
out.keyword('Hello').breakable.text('World')

puts out.output
# \e[31mHello\e[0m World
```

The same idea can be applied an adapted to make an HTML printer; all you need to take care of is the correct width of the text to preserve the width of the text and get an output identical to that of the tty colored printer.

Check out the [examples/](examples/README.md) folder for more details on how to use the Oppen and Wadler APIs.

## Difference With Oppen's Original Algorithm

1. We took the liberty to rename functions to make the API more modern and closer to
what we expect when writing Ruby code.  All correspondences with the algorithm
as described in Oppen's paper are noted in the comments of classes and methods.
1. We do not raise exceptions when we overflow the margin. The only exceptions
that we raise indicate a bug in the implementation. Please report them.
1. The stacks described by the algorithm do not have a fixed size in our
implementation: we upsize them when they are full.
1. We can optionally trim trailing whitespaces (this feature is on by default for the `Wadler` API).
1. We added support for an additional new line anchors, see [examples/configs/indent_anchor.rb](examples/configs/indent_anchor.rb).
1. We added support for eager printing of `groups`; see [examples/configs/eager_print.rb](examples/configs/eager_print.rb).
1. We introduced a new token (`Whitespace`) and added more customizations to one of the originals (`Break`).

For more insight on how Oppen's algorithm works, check out [docs/oppen_algorithm.md](docs/oppen_algorithm.md).

## Related Projects

1. [`ruby/prettyprint`](https://github.com/ruby/prettyprint)
1. [rustc implementation](https://doc.rust-lang.org/nightly/nightly-rustc/rustc_ast_pretty/pp/index.html)
1. [`stevej2608/oppen-pretty-printer`](https://github.com/stevej2608/oppen-pretty-printer) as a library.
