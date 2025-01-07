# frozen_string_literal: true

require_relative '../helper'

printer_with_config = Oppen::Wadler.new config: Oppen::Config.new(eager_print: true), width: 13
printer_no_config   = Oppen::Wadler.new config: Oppen::Config.new,                    width: 13
test_block = ->(printer) {
  printer.group {
    printer.group {
      printer.text 'abc'
      printer.breakable
      printer.text 'def'
    }
    printer.group {
      printer.text 'ghi'
      printer.breakable
      printer.text 'jkl'
    }
  }
}
test_block.(printer_with_config)
test_block.(printer_no_config)

title 'With eager printing:'
puts printer_with_config.output
# abc defghi
#        jkl

puts ''

title 'Without eager printing:'
puts printer_no_config.output
# abc
# defghi jkl
