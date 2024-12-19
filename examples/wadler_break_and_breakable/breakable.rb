# frozen_string_literal: true

require_relative '../helper'

# Locations that can produce a new line if the current line is wider than the maximum width
# can be specified using the breakable token.

printer = Oppen::Wadler.new(width: 40)

# See `examples/wadler_group/inconsistent.rb` for more infos about `Oppen::Token::BreakType::INCONSISTENT`
printer.group(0, '', '', Oppen::Token::BreakType::INCONSISTENT) {
  printer.text 'Hello, World!'
  printer.breakable
  printer.text '(still fits on the line)'
  printer.breakable
  printer.text 'How are you doing?'
}

puts printer.output
# Hello, World! (still fits on the line)
# How are you doing?
