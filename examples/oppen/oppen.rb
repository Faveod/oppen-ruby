# frozen_string_literal: true

require_relative '../helper'

# ❗ Make sure to always end your tokens list by an EOF token,
# and make sure that every String Token is inside a group.
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
