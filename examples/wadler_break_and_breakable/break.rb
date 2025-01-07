# frozen_string_literal: true

require_relative '../helper'

# A new line can be forced by using the break token.

printer = Oppen::Wadler.new(width: 999_999)

printer.text 'Hello, World!'
printer.break
printer.text 'How are you doing?'

puts printer.output
# Hello, World!
# How are you doing?
