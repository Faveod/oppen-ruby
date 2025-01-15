# frozen_string_literal: true

require_relative '../helper'

# The new line String can be specified using the `new_line` parameter.
new_line = '<br>'

printer = Oppen::Wadler.new(indent: 2, new_line:)

printer.group {
  printer.text 'Hello, World!'
  printer.break
  printer.text 'How are you doing?'
  printer.break
  printer.text 'I am fine'
}

puts printer.output
# Hello, World!<br>  How are you doing?<br>  I am fine
