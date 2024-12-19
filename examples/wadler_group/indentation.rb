# frozen_string_literal: true

require_relative '../helper'

printer = Oppen::Wadler.new(width: 999_999)

# Groups have an indentation of 0 by default.
printer.group(4) {
  printer.text 'Hello, World!'
  printer.break
  printer.text 'How are you doing?'
  printer.break
  printer.text 'I am fine, thanks.'
  printer.break
  printer.text 'GoodBye, World!'
}

puts printer.output
# Hello, World!
#     How are you doing?
#     I am fine, thanks.
#     GoodBye, World!
