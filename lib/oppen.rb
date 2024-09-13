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
  # @param margin [Integer] maximum line width desired
  # @param new_line [String] the delimiter between lines
  #
  # @return [StringIO] output of the pretty printer
  def self.print(tokens: [], margin: 80, new_line: "\n")
    printer = Printer.new margin, new_line
    tokens.each do |token|
      printer.print token
    end
    printer.output
  end
end
