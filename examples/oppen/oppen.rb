# frozen_string_literal: true

require_relative '../helper'

# ❗ Always end the tokens list by an EOF token (it acts as a flush),
# and every String Token should be inside a group.
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
