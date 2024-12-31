# frozen_string_literal: true

require_relative '../helper'

printer = Oppen::Wadler.new

printer.group(2) {
  printer.text 'Hello, World!'
  printer.nest(4) {
    printer.break
    printer.text 'GoodBye, World!'
  }
}

puts printer.show_print_commands
# out.group(:consistent, indent: 2) {
#   out.text("Hello, World!", width: 13)
#   out.nest(indent: 4) {
#     out.break(line_continuation: "")
#   }
#   out.text("GoodBye, World!", width: 15)
# }
