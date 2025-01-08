# frozen_string_literal: true

require_relative '../helper'

# You might want to also take a look at the `parens`, `parens_break_both`, `angles`, ... methods.

printer = Oppen::Wadler.new(width: 10)

printer.surround('<<', '>>', indent: 2, lft_force_break: true, rgt_force_break: true) {
  printer.text '42'
}

puts printer.output
# <<
#   42
#   >>
