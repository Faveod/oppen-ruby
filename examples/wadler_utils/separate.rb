# frozen_string_literal: true

require_relative '../helper'

# You might want to also take a look at the `lines` and `concat` methods.

printer = Oppen::Wadler.new(width: 10)

printer.separate((1..10).map(&:to_s), ',', break_type: :inconsistent, indent: 2) { |i|
  printer.text i
}

puts printer.output
# 1, 2, 3,
#   4, 5, 6,
#   7, 8, 9,
#   10
