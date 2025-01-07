# frozen_string_literal: true

require_relative '../helper'

# A String to write before a new line can be specified
# by using the `line_continuation` argument of `break` and `breakable`.
# `line_continuation` defaults to an empty String.

printer = Oppen::Wadler.new(width: 999_999)

printer.text 'Hello, World!'
printer.break
printer.text 'How are you doing?'
printer.break line_continuation: ' (this will be printed before the new line)'
printer.text 'GoodBye, World!'

puts printer.output
# Hello, World!
# How are you doing? (this will be printed before the new line)
# GoodBye, World!
