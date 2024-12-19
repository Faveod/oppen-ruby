# frozen_string_literal: true

require_relative 'example'

# Examples for all the possible configs.

# Eager printing.
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

puts "# Eager printing\n".title
puts 'With eager printing:'.sub_title
puts printer_with_config.output
# Output:
# abc defghi
# jkl
puts ''
puts 'Without eager printing:'.sub_title
puts printer_no_config.output
# Output:
# abc
# defghi jkl
puts ''

# Indent anchor.
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
puts "# Indent anchor\n".title
puts 'ON_BEGIN:'.sub_title
puts printer_with_config.output
# Output:
# And she said:
#         Hello, World!
puts ''
puts 'ON_BREAK:'.sub_title
puts printer_no_config.output
# Output:
# And she said:
#                  Hello, World!
puts ''

# Trim trailing whitespaces.
printer_with_config = Oppen::Wadler.new config: Oppen::Config.new(trim_trailing_whitespaces: true), width: 13
printer_no_config   = Oppen::Wadler.new config: Oppen::Config.new,                                  width: 13
test_block = ->(printer) {
  printer.text 'Hello, World!   '
  printer.break
  printer.text 'How are you?'
}
test_block.(printer_with_config)
test_block.(printer_no_config)
puts "# Trim trailing whitespaces\n".title
puts 'With trim trailing whitespaces:'.sub_title
puts printer_with_config.output
# Output:
# Hello, World!$
# How are you?$
puts ''
puts 'Without trim trailing whitespaces:'.sub_title
puts printer_no_config.output
# Output:
# Hello, World!   $
# How are you?$
puts ''

# Upsize stack.
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
puts "# Upsize stack\n".title
puts 'With upsize stack:'.sub_title
puts printer_with_config.output
# Output:
# Hello, World!$
puts ''
puts 'Without upsize stack:'.sub_title
begin
  puts printer_no_config.output
rescue RuntimeError
  puts 'Token queue full'
end
# Output:
# Token queue full
puts ''
