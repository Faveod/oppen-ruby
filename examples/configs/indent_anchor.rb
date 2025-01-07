# frozen_string_literal: true

require_relative '../helper'

printer_with_config =
  Oppen::Wadler.new(
    config: Oppen::Config.new(indent_anchor: :current_offset),
    indent: 4,
    width: 13,
  )
printer_no_config =
  Oppen::Wadler.new(
    config: Oppen::Config.new(indent_anchor: :end_of_previous_line),
    indent: 4,
    width: 13,
  )
test_block = ->(printer) {
  printer.text 'And she said:'
  printer.group {
    printer.group {
      printer.break
      printer.text 'Hello, World!'
    }
  }
}
test_block.(printer_with_config)
test_block.(printer_no_config)

title ':current_offset:'
puts printer_with_config.output
# And she said:
#         Hello, World!

puts ''

title ':end_of_previous_line:'
puts printer_no_config.output
# And she said:
#                  Hello, World!
