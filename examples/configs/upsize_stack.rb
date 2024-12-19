# frozen_string_literal: true

require_relative '../helper'

# Our implementation of Oppen's algorithm extends the original approach by allowing the stacks to grow if needed,
# which happens when it tries to print a line that overflows the defined line width.

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

title 'With upsize stack:'
puts printer_with_config.output
# Hello, World!

puts ''

title 'Without upsize stack:'
begin
  puts printer_no_config.output
rescue RuntimeError
  puts 'Token queue full'
end
# Token queue full
