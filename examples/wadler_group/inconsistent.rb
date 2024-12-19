# frozen_string_literal: true

require_relative '../helper'

# In a consistent group, The presence of a new line inside the group will not propagate
# to the other Break tokens in the group letting them decide if they need to act as a new line or not.

printer = Oppen::Wadler.new(width: 999_999)

printer.group(0, '', '', Oppen::Token::BreakType::INCONSISTENT) {
  printer.text 'Hello, World!'
  printer.breakable
  printer.text 'How are you doing?'
  printer.break
  printer.text 'I am fine, thanks.'
  printer.breakable
  printer.text 'GoodBye, World!'
}

puts printer.output
# Hello, World! How are you doing?
# I am fine, thanks. GoodBye, World!
