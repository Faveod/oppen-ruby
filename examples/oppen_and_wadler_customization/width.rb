# frozen_string_literal: true

require_relative '../helper'

# The maximum width can be specified using the `width` parameter.
width = 5

printer_width_default = Oppen::Wadler.new
printer_width_narrow = Oppen::Wadler.new(width: width)
test_block = ->(printer) {
  printer.group(2) {
    printer.text 'Hello, World!'
    printer.breakable
    printer.text 'How are you doing?'
    printer.breakable
    printer.text 'I am fine'
  }
}
test_block.(printer_width_default)
test_block.(printer_width_narrow)

title 'With narrow width:'
puts printer_width_narrow.output
# Hello, World!
#   How are you doing?
#   I am fine

puts ''

title 'With default width:'
puts printer_width_default.output
# Hello, World! How are you doing? I am fine
