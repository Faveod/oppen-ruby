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
    attr_accessor :indent_anchor

    # @param eager_print               [Boolean] whether to eagerly print.
    # @param indent_anchor             [Symbol]  the different ways of handling the indentation of nested groups.
    # :end_of_previous_line =>
    # In the case of a new line in a nested group,
    # the next string token will be displayed with
    # indentation = previous line width + last group indentation.
    # Defined in Oppen's paper.
    #
    # :current_offset =>
    # When printing a new line in a nested group,
    # the next string token will be displayed with an
    # indentation equal to the sum of the indentations of all
    # its parent groups.
    # This is an extension to Oppen's work.
    # @param trim_trailing_whitespaces [Boolean] whether to trim trailing whitespaces.
    # @param upsize_stack              [Boolean] whether to upsize stack when needed.
    #
    # @example :end_of_previous_line anchor
    #   config = Oppen::Config.new(indent_anchor: :end_of_previous_line)
    #   out = Oppen::Wadler.new config:, width: 13
    #   out.text 'And she said:'
    #   out.group(4) {
    #     out.group(4) {
    #       out.break
    #       out.text 'Hello, World!'
    #     }
    #   }
    #   out.output
    #
    #   # =>
    #   # And she said:
    #   #                  Hello, World!
    #
    # @example :current_offset anchor
    #   config = Oppen::Config.new(indent_anchor: :current_offset)
    #   out = Oppen::Wadler.new config:, width: 13
    #   out.text 'And she said:'
    #   out.group(4) {
    #     out.group(4) {
    #       out.break
    #       out.text 'Hello, World!'
    #     }
    #   }
    #   out.output
    #
    #   # =>
    #   # And she said:
    #   #         Hello, World!
    def initialize(eager_print: false, indent_anchor: :end_of_previous_line,
                   trim_trailing_whitespaces: false, upsize_stack: false)
      @eager_print = eager_print
      @indent_anchor = indent_anchor
      @trim_trailing_whitespaces = trim_trailing_whitespaces
      @upsize_stack = upsize_stack
    end

    # Print groups eagerly.
    #
    # @example
    #   out = Oppen::Wadler.new(width: 13)
    #   out.group {
    #     out.group {
    #       out.text 'abc'
    #       out.breakable
    #       out.text 'def'
    #     }
    #     out.group {
    #       out.text 'ghi'
    #       out.breakable
    #       out.text 'jkl'
    #     }
    #   }
    #   out.output
    #
    #   # eager_print: false =>
    #   # abc
    #   # defghi jkl
    #   #
    #   # eager_print: true =>
    #   # abc defghi
    #   # jkl
    #
    # @return [Boolean]
    def eager_print? = @eager_print

    def trim_trailing_whitespaces? = @trim_trailing_whitespaces

    def upsize_stack? = @upsize_stack

    # Default configuration that provides printing behaviour
    # identical to what's been described by Oppen.
    #
    # @return [Config]
    def self.oppen
      new
    end

    # Configure the printer to behave more like [ruby/prettyprint](https://github.com/ruby/prettyprint):
    #
    # 1. groups are printed eagerly (we try to flush on a group's close).
    # 2. The indentation is anchored on the left margin.
    # 3. Trailing whitespaces are removed.
    #
    # The name was amusingly chosen in reference to [Wadler](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf)'s
    # work on pretty printing.
    #
    # @return [Config]
    def self.wadler(eager_print: true, trim_trailing_whitespaces: true, upsize_stack: true)
      new(eager_print:, indent_anchor: :current_offset, trim_trailing_whitespaces:, upsize_stack:)
    end
  end

  # @param value [String]  the string to print.
  # @param width [Integer] the string's effective width. Useful when printing HTML,
  #                        e.g. `<span>value</span>`, where the effective width is that of the inner text.
  #
  # @return [Token::String] a new String token.
  def self.string(value, width: value.length)
    Token::String.new(value, width:)
  end

  # @return [Token::Whitespace] a new Whitespace token.
  def self.whitespace(value)
    Token::Whitespace.new(value, width: value.bytesize)
  end

  # @param str               [String]  value shown if no new line is needed.
  # @param line_continuation [String]  printed before the line break.
  # @param offset            [Integer] additional indentation to be added to the current indentation level.
  # @param width             [Integer] the string's effective width. Useful when printing HTML,
  #                                    e.g. `<span>value</span>`, where the effective width is that of the inner text.
  #
  # @return [Token::Break] a new Break token.
  #
  # @see Wadler#break for an example on `line_continuation`.
  def self.break(str = ' ', line_continuation: '', offset: 0, width: str.length)
    Token::Break.new(str, width:, line_continuation:, offset:)
  end

  # @param line_continuation [String]  printed before the line break.
  # @param offset            [Integer] additional indentation to be added to the current indentation level.
  #
  # @return [Token::LineBreak] a new LineBreak token.
  #
  # @see Wadler#break for an example on `line_continuation`.
  def self.line_break(line_continuation: '', offset: 0)
    Token::LineBreak.new(line_continuation:, offset:)
  end

  # In a consistent group,
  # The presence of a new line inside the group will propagate
  # to the other Break tokens in the group
  # causing them all to act as a new line.
  #
  # @param offset [Integer] the additional indentation of the group.
  #
  # @return [Token::Begin] a new consistent Begin token.
  #
  # @example when used for the display of a function's arguments.
  #   fun(
  #       arg1,
  #       arg2,
  #       arg3,
  #       arg4,
  #      )
  #
  # @see Wadler#group
  def self.begin_consistent(offset: 2)
    Token::Begin.new(break_type: :consistent, offset:)
  end

  # In an inconsistent group,
  # the presence of a new line inside the group will not propagate
  # to the other Break tokens in the group letting them decide
  # if they need to act as a new line or not.
  #
  # @param offset [Integer] the additional indentation of the group.
  #
  # @return [Token::Begin] a new inconsistent Begin token.
  #
  # @example when used for the display of a function's arguments.
  #   fun(
  #       arg1, arg2,
  #       arg3, arg4,
  #      )
  #
  # @see Wadler#group
  def self.begin_inconsistent(offset: 2)
    Token::Begin.new(break_type: :inconsistent, offset:)
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
