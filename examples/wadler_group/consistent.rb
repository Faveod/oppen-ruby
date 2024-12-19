# frozen_string_literal: true

require_relative '../helper'

# In a consistent group, the presence of a new line inside the group will propagate
# to the other Break tokens in the group causing them all to act as a new line.

printer = Oppen::Wadler.new(width: 999_999)

# Groups are consistent by default.
printer.group {
  printer.text 'Hello, World!'
  printer.breakable
  printer.text 'How are you doing?'
  printer.break
  printer.text 'I am fine, thanks.'
  printer.breakable
  printer.text 'GoodBye, World!'
}

puts printer.output
# Hello, World!
# How are you doing?
# I am fine, thanks.
# GoodBye, World!
