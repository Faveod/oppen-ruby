# frozen_string_literal: true

require_relative 'oppen/printer'
require_relative 'oppen/print_stack'
require_relative 'oppen/scan_stack'
require_relative 'oppen/token'
require_relative 'oppen/version'

# Oppen.
module Oppen
  # Entry point of the pretty printer.
  #
  # @param tokens [Array[Token]] the list of tokens to be printed
  # @param line_width [Integer] maximum line width desired
  # @param line_delimiter [String] the delimiter between lines
  #
  # @return [StringIO] output of the pretty printer
  def self.print(tokens: [], line_width: 80, line_delimiter: "\n")
    printer = Printer.new line_width, line_delimiter
    tokens.each do |token|
      printer.print token
    end
    printer.output
  end
end
