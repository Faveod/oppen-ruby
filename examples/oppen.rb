# frozen_string_literal: true

require_relative 'example'

# Examples on how to use Oppen, more precisely Oppen.print method.

# ❗ Make sure to always end your tokens list by an EOF token,
#    and make sure that every String Token is inside a group.
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

# With the default parameters.
puts 'With the default parameters:'.title
puts Oppen.print(tokens:)
# Output
# Hello, World!
#   How are you doing?
puts ''

# The space parameter.
# You can customize the indentation character.
# By using a string:
_space = '#'
# By using a callable:
space = ->(n) { '---' * n }
puts 'With the space parameter:'.title
puts Oppen.print(tokens:, space:)
# Output
# Hello, World!
# ------How are you doing?oing?
puts ''
