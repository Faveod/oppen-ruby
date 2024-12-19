# frozen_string_literal: true

require_relative 'oppen/mixins'
require_relative 'oppen/printer'
require_relative 'oppen/print_stack'
require_relative 'oppen/scan_stack'
require_relative 'oppen/token'
require_relative 'oppen/version'
require_relative 'wadler/print'

# Oppen.
module Oppen
  extend Mixins

  # Entry point of the pretty printer.
  #
  # @param config   [Config]       to customize the printer's behavior.
  # @param new_line [String]       the delimiter between lines.
  # @param out      [Object]       the output string buffer.
  #                                It should have a `write` and `string` methods.
  # @param space    [String, Proc] indentation string or a code that generates the indentation string.
  #   If it's a string, spaces will be generated with the the
  #   lambda `->(n){ space * n }`, where `n` is the number of columns
  #   to indent.
  #   If it's a callable, it will receive `n` and it needs to return
  #   a string.
  # @param tokens   [Array<Token>] the list of tokens to be printed.
  # @param width    [Integer]      maximum line width desired.
  #
  # @return [String] output of the pretty printer.
  def self.print(config: Config.oppen, new_line: "\n",
                 out: StringIO.new, space: ' ', tokens: [], width: 80)
    printer = Printer.new width, new_line, config, space, out
    tokens.each do |token|
      printer.print token
    end
    printer.output
  end

  # Config.
  class Config
    # IndentAnchor (cf. test/indent_anchor_test.rb).
    # The different ways of handling the indentation of nested groups.
    #
    # ON_BREAK => Anchor on break position (cf. Oppen's original paper).
    #             In the case of a new line in a nested group,
    #             the next string token will be displayed with
    #             indentation = previous line width + last group indentation.
    #
    # ON_BEGIN => Anchor on begin block position.
    #             In the case of a new line in a nested group,
    #             the next string token will be displayed with
    #             indentation = the sum of the indentations of all its parent groups.
    module IndentAnchor
      # @return [Integer]
      ON_BREAK = 0
      # @return [Integer]
      ON_BEGIN = 1
    end

    attr_accessor :indent_anchor

    def initialize(eager_print: false, indent_anchor: IndentAnchor::ON_BREAK,
                   trim_trailing_whitespaces: false, upsize_stack: false)
      @eager_print = eager_print
      @indent_anchor = indent_anchor
      @trim_trailing_whitespaces = trim_trailing_whitespaces
      @upsize_stack = upsize_stack
    end

    # Print groups eagerly.
    #
    # @example
    #  out = Oppen::Wadler.new (width: 13)
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

    def trim_trailing_whitespaces? = @trim_trailing_whitespaces

    def upsize_stack? = @upsize_stack

    # Default configuration that provides printing behaviour
    # identical to what's been described by Oppen
    #
    # @return [Config]
    def self.oppen
      new
    end

    # Configuration that provides printing behavior that deviates from Oppen's original algorithm:
    # 1. …
    # 2. …
    #
    # … which makes it closer to [`ruby/prettyprint`](…).
    #
    # The name was amusingly chosen in reference to Wadler's work on
    # pretty printing.
    #
    # @return [Config]
    def self.wadler(eager_print: true, trim_trailing_whitespaces: true, upsize_stack: true)
      new(eager_print:, indent_anchor: IndentAnchor::ON_BEGIN, trim_trailing_whitespaces:, upsize_stack:)
    end
  end

  # @param value [String]  the string to print.
  # @param width [Integer] token width.
  #
  # @return [Token::String] a new String token.
  def self.string(value, width: value.length)
    Token::String.new(value, width:)
  end

  # @return [Token::Whitespace] a new Whitespace token.
  #
  # @see Token::Whitespace
  def self.whitespace(value)
    Token::Whitespace.new(value, width: value.bytesize)
  end

  # @param str               [String]  value shown if no new line is needed.
  # @param line_continuation [String]  if a new line is issued, this string will show just before
  #                                    the new line.
  # @param offset            [Integer] the additional indentation of the break.
  # @param width             [Integer] token width.
  #
  # @return [Token::Break] a new Break token.
  def self.break(str = ' ', line_continuation: '', offset: 0, width: str.length)
    Token::Break.new(str, width:, line_continuation:, offset:)
  end

  # @param line_continuation [String]  if a new line is needed display this string at the beginning of
  #                                    the new line, at the specified anchor position.
  # @param offset            [Integer] the additional indentation of the break.
  #
  # @return [Token::LineBreak] a new LineBreak token.
  def self.line_break(line_continuation: '', offset: 0)
    Token::LineBreak.new(line_continuation:, offset:)
  end

  # @param offset [Integer] the additional indentation of the group.
  #
  # @return [Token::Begin] a new consistent Begin token.
  def self.begin_consistent(offset: 2)
    Token::Begin.new(break_type: Token::BreakType::CONSISTENT, offset:)
  end

  # @param offset [Integer] the additional indentation of the group.
  #
  # @return [Token::Begin] a new inconsistent Begin token.
  def self.begin_inconsistent(offset: 2)
    Token::Begin.new(break_type: Token::BreakType::INCONSISTENT, offset:)
  end

  # @return [Token::End] a new End token.
  def self.end
    Token::End.new
  end

  # @return [Token::EOF] a new EOF token.
  def self.eof
    Token::EOF.new
  end
end
