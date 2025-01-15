# frozen_string_literal: true

require_relative '../helper'

# ❗ This feature is only available for wadler at the time being, and only when the
# `trim_trailing_whitespaces` config is active.

# The value of the whitespace string that will be trimmed in order
# to prevent trailing whitespaces can be specified using the `whitespace` parameter.
whitespace = '**'

printer = Oppen::Wadler.new(indent: 2, whitespace:)

printer.group {
  printer.text '******Hello, World!******'
  printer.break
}

puts printer.output
# ******Hello, World!
