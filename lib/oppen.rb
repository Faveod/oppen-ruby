# frozen_string_literal: true

require_relative 'oppen/printer'
require_relative 'oppen/print_stack'
require_relative 'oppen/scan_stack'
require_relative 'oppen/token'
require_relative 'oppen/version'
require_relative 'wadler/print'

# Oppen.
module Oppen
  # Entry point of the pretty printer.
  #
  # @param config [Config]
  # @param space [String, Proc] could be a String or a callable.
  #   If it's a string, spaces will be generated with the the
  #   lambda `->(n){ n * space }`, where `n` is the number of columns
  #   to indent.
  #   If it's a callable, it will receive `n` and it needs to return
  #   a string.
  # @param margin [Integer] maximum line width desired
  # @param new_line [String] the delimiter between lines
  # @param out [Object] should have a write and string method
  # @param tokens [Array[Token]] the list of tokens to be printed
  #
  # @return [String] output of the pretty printer
  def self.print(config: Config.oppen, space: ' ',
                 margin: 80, new_line: "\n", out: StringIO.new, tokens: [])
    printer = Printer.new margin, new_line, config, space, out
    tokens.each do |token|
      printer.print token
    end
    printer.output
  end

  # Config.
  class Config
    # IndentAnchor.
    #
    # ON_BREAK => anchor on break position (as in Oppen's original paper)
    # ON_BEGIN => anchor on begin block position
    module IndentAnchor
      # @return [Integer]
      ON_BREAK = 0
      # @return [Integer]
      ON_BEGIN = 1
    end

    attr_accessor :indent_anchor

    def initialize(indent_anchor: IndentAnchor::ON_BREAK, eager_print: false, upsize_stack: false)
      @indent_anchor = indent_anchor
      @eager_print = eager_print
      @upsize_stack = upsize_stack
    end

    # Print groups eagerly
    #
    # @example
    #  out = Oppen::Wadler.new (margin: 13)
    #  out.group {
    #    out.group {
    #      out.text 'abc'
    #      out.breakable
    #      out.text 'def'
    #    }
    #    out.group {
    #      out.text 'ghi'
    #      out.breakable
    #      out.text 'jkl'
    #    }
    #  }
    #  out.output
    #
    #  # eager_print: false
    #  # =>
    #  # abc
    #  # defghi jkl
    #  #
    #  # eager_print: true
    #  # =>
    #  # abc defghi
    #  # jkl
    #
    # @return [Boolean]
    def eager_print? = @eager_print

    def upsize_stack? = @upsize_stack

    # Default config for Oppen usage
    # @return [Config]
    def self.oppen
      new
    end

    # Default config for Wadler usage
    # @return [Config]
    def self.wadler(eager_print: true, upsize_stack: true)
      new(indent_anchor: IndentAnchor::ON_BEGIN, eager_print:, upsize_stack:)
    end
  end

  # @param value [String]
  #
  # @return [Oppen::Token::String] a new String token
  def self.string(value)
    Token::String.new(value)
  end

  # @param str [String]
  # @param line_continuation [String] If a new line is needed display this string before the new line
  # @param offset [Integer]
  #
  # @return [Oppen::Token::Break] a new Break token
  def self.break(str = ' ', line_continuation: '', offset: 0)
    Token::Break.new(str, line_continuation:, offset:)
  end

  # @param line_continuation [String] If a new line is needed display this string before the new line
  # @param offset [Integer]
  #
  # @return [Oppen::Token::LineBreak] a new LineBreak token
  def self.line_break(line_continuation: '', offset: 0)
    Token::LineBreak.new(line_continuation:, offset:)
  end

  # @param offset [Integer]
  #
  # @return [Oppen::Token::Begin] a new consistent Begin token
  def self.begin_consistent(offset: 2)
    Token::Begin.new(break_type: Token::BreakType::CONSISTENT, offset:)
  end

  # @param offset [Integer]
  #
  # @return [Oppen::Token::Begin] a new inconsistent Begin token
  def self.begin_inconsistent(offset: 2)
    Token::Begin.new(break_type: Token::BreakType::INCONSISTENT, offset:)
  end

  # @return [Oppen::Token::End] a new End token
  def self.end
    Token::End.new
  end

  # @return [Oppen::Token::EOF] a new EOF token
  def self.eof
    Token::EOF.new
  end
end
