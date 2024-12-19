# frozen_string_literal: true

require_relative '../helper'

printer_with_config = Oppen::Wadler.new config: Oppen::Config.new(trim_trailing_whitespaces: true), width: 13
printer_no_config   = Oppen::Wadler.new config: Oppen::Config.new,                                  width: 13
test_block = ->(printer) {
  printer.text 'Hello, World!   '
  printer.break
  printer.text 'How are you?'
}
test_block.(printer_with_config)
test_block.(printer_no_config)

title 'With trim trailing whitespaces:'
puts printer_with_config.output
# Hello, World!$
# How are you?$

puts ''

title 'Without trim trailing whitespaces:'
puts printer_no_config.output
# Hello, World!   $
# How are you?$
