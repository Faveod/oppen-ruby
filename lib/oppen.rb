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
  # @param margin [Integer] maximum line width desired
  # @param new_line [String] the delimiter between lines
  # @param tokens [Array[Token]] the list of tokens to be printed
  #
  # @return [StringIO] output of the pretty printer
  def self.print(config: Config.oppen, margin: 80, new_line: "\n", tokens: [])
    printer = Printer.new margin, new_line, config
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

    def initialize(indent_anchor: IndentAnchor::ON_BREAK)
      @indent_anchor = indent_anchor
    end

    # Default config for Oppen usage
    # @return [Config]
    def self.oppen
      new
    end

    # Default config for Wadler usage
    # @return [Config]
    def self.wadler
      new(indent_anchor: IndentAnchor::ON_BEGIN)
    end
  end

  # @param value [String]
  #
  # @return [Oppen::Token::String] a new String token
  def self.string(value)
    Token::String.new(value)
  end

  # @param blank_space [Integer]
  # @param offset [Integer]
  #
  # @return [Oppen::Token::Break] a new Break token
  def self.break(blank_space: 1, offset: 0)
    Token::Break.new(blank_space:, offset:)
  end

  # @param offset [Integer]
  #
  # @return [Oppen::Token::LineBreak] a new LineBreak token
  def self.line_break(offset: 0)
    Token::LineBreak.new(offset:)
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
