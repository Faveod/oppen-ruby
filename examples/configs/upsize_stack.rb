# frozen_string_literal: true

require_relative '../helper'

printer_with_config = Oppen::Wadler.new config: Oppen::Config.new(upsize_stack: true), width: 1
printer_no_config   = Oppen::Wadler.new config: Oppen::Config.new,                     width: 1
test_block = ->(printer) {
  printer.group {
    printer.group {
      printer.group {
        printer.text 'Hello, World!'
      }
    }
  }
}
test_block.(printer_with_config)
test_block.(printer_no_config)

puts 'With upsize stack:'.sub_title
puts printer_with_config.output
# Hello, World!

puts ''

puts 'Without upsize stack:'.sub_title
begin
  puts printer_no_config.output
rescue RuntimeError
  puts 'Token queue full'
end
# Token queue full
