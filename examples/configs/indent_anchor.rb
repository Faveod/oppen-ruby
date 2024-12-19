# frozen_string_literal: true

require_relative '../helper'

printer_with_config =
  Oppen::Wadler.new(
    config: Oppen::Config.new(indent_anchor: Oppen::Config::IndentAnchor::CURRENT_OFFSET),
    width: 13,
  )
printer_no_config =
  Oppen::Wadler.new(
    config: Oppen::Config.new(indent_anchor: Oppen::Config::IndentAnchor::END_OF_PREVIOUS_LINE),
    width: 13,
  )
test_block = ->(printer) {
  printer.text 'And she said:'
  printer.group(4) {
    printer.group(4) {
      printer.break
      printer.text 'Hello, World!'
    }
  }
}
test_block.(printer_with_config)
test_block.(printer_no_config)

title 'CURRENT_OFFSET:'
puts printer_with_config.output
# And she said:
#         Hello, World!

puts ''

title 'END_OF_PREVIOUS_LINE:'
puts printer_no_config.output
# And she said:
#                  Hello, World!
