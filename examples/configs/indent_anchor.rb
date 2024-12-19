# frozen_string_literal: true

require_relative '../helper'

on_begin_config = Oppen::Config::IndentAnchor::ON_BEGIN
on_break_config = Oppen::Config::IndentAnchor::ON_BREAK
printer_with_config = Oppen::Wadler.new config: Oppen::Config.new(indent_anchor: on_begin_config), width: 13
printer_no_config   = Oppen::Wadler.new config: Oppen::Config.new(indent_anchor: on_break_config), width: 13
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

puts 'ON_BEGIN:'.sub_title
puts printer_with_config.output
# And she said:
#         Hello, World!

puts ''

puts 'ON_BREAK:'.sub_title
puts printer_no_config.output
# And she said:
#                  Hello, World!
