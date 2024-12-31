# frozen_string_literal: true

require_relative '../helper'

# The indentation character can be specified using the `space` parameter.

# By using a string:
_space = '#'
# By using a callable:
space = ->(n) { '---' * n }

printer = Oppen::Wadler.new(indent: 2, space: space)

printer.group {
  printer.text 'Hello, World!'
  printer.break
  printer.text 'How are you doing?'
  printer.group {
    printer.break
    printer.text 'I am fine'
  }
}

puts printer.output
# Hello, World!
# ------How are you doing?
# ------------I am fine
