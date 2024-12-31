# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    # @return [Config]
    #   The printer's configuration, altering its behavior.
    attr_reader :config
    # @return [Integer]
    #   the current indentation amount.
    attr_reader :current_indent
    # @return [String]
    #   the new line string, e.g. `\n`.
    attr_reader :new_line
    # @return [Object]
    #   the output string buffer. It should have a `write` and `string` methods.
    attr_reader :out
    # @return [Proc]
    #   space generator, a callable.
    attr_reader :space
    # @return [Array<Token>]
    #   the tokens list that is being built.
    attr_reader :tokens
    # @return [String]
    #   the whitespace character. Used to trim trailing whitespaces.
    attr_reader :whitespace
    # @return [Integer]
    #   maximum line width.
    attr_reader :width

    # @param base_indent     [Integer]
    #   the starting indentation level for the whole printer.
    # @param config     [Config]
    #   to customize the printer's behavior.
    # @param indent     [Integer]
    #   the default indentation amount for {group} and {nest}.
    # @param new_line   [String]
    #   the new line String.
    # @param out        [Object]
    #   the output string buffer. It should have a `write` and `string` methods.
    # @param space      [String, Proc]
    #   indentation string or a string generator.
    #   - If a `String`, spaces will be generated with the the lambda
    #     `->(n){ space * n }`, where `n` is the number of columns to indent.
    #   - If a `Proc`, it will receive `n` and it needs to return a `String`.
    # @param whitespace [String]       the whitespace character. Used to trim trailing whitespaces.
    # @param width      [Integer]      maximum line width desired.
    #
    # @see Token::Whitespace
    def initialize(base_indent: 0, config: Config.wadler, indent: 0, new_line: "\n",
                   out: StringIO.new, space: ' ',
                   whitespace: ' ', width: 80)
      @config = config
      @current_indent = base_indent
      @indent = indent
      @new_line = new_line
      @out = out
      @space = space
      @tokens = []
      @whitespace = whitespace
      @width = width
    end

    # Add missing {Token::Begin}, {Token::End} or {Token::EOF}.
    #
    # @return [Nil]
    def add_missing_begin_and_end
      if !tokens.first.is_a? Token::Begin
        tokens.unshift Oppen.begin_consistent(offset: 0)
        tokens << Oppen.end
      end
      tokens << Oppen.eof if !tokens.last.is_a?(Oppen::Token::EOF)
    end

    # Call this to extract the final pretty-printed output.
    #
    # @return [String]
    def output
      add_missing_begin_and_end
      Oppen.print(
        tokens: tokens,
        new_line: new_line,
        config: config,
        space: space,
        out: out,
        width: width,
      )
    end

    # Convert a list of tokens to its wadler representation.
    #
    # This method reverse engineers a tokens list to transform it into Wadler
    # printing commands. It can be particularly useful when debugging a black
    # box program.
    #
    # @option kwargs [Integer] :base_indent
    #   the base indentation amount of the output.
    # @option kwargs [String]  :printer_name
    #   the name of the Wadler instance in the output.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.group {
    #     out.text('Hello World!')
    #   }
    #   out.show_print_commands(out_name: 'out')
    #
    #   # =>
    #   # out.group(:consistent, indent: 0) {
    #   #   out.text("Hello World!", width: 12)
    #   # }
    #
    # @return [String]
    def show_print_commands(**kwargs)
      add_missing_begin_and_end
      Oppen.tokens_to_wadler(tokens, **kwargs)
    end

    # Create a new group.
    #
    # @param indent    [Integer]
    #   indentation.
    # @param delim     [Nil|String|Symbol|Array<Nil, String, Symbol>]
    #   delimiters, to be printed at the start and the end of the group:
    #   - If it's nil, nothing will be printed
    #   - If it's a Strings or a Symbol, it will be printed at both positions.
    #   - If it's an Array of many items, the first two elements will be used
    #     for the start and end of the group.
    # @param break_type [Token::BreakType]
    #   break type.
    #
    # @yield
    #   the block of text in a group.
    #
    # @example 1 String Delimiter
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.group(indent: 2, delim: '|') {
    #     out.break
    #     out.text 'b'
    #   }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   #   |
    #   #   b
    #   #   |
    #
    # @example 1 Delimiter in Array
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.group(indent: 2, delim: ['|']) {
    #     out.break
    #     out.text 'b'
    #   }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   #   |
    #   #   b
    #
    # @example 2 Delimiters
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.group(indent: 2, delim: %i[{ }]) {
    #     out.break
    #     out.text 'b'
    #   }
    #   out.output
    #
    #   # =>
    #   # a
    #   #   {
    #   #   b
    #   #   }
    #
    # @example Consistent Breaking
    #   out = Oppen::Wadler.new
    #   out.group(:consistent) {
    #     out.text 'a'
    #     out.break
    #     out.text 'b'
    #     out.breakable
    #     out.text 'c'
    #   }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   # b
    #   # c
    #
    # @example Inconsistent Breaking
    #   out = Oppen::Wadler.new
    #   out.group(:inconsistent) {
    #     out.text 'a'
    #     out.break
    #     out.text 'b'
    #     out.breakable
    #     out.text 'c'
    #   }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   # b c
    #
    # @return [Nil]
    #
    # @see Oppen.begin_consistent
    # @see Oppen.begin_inconsistent
    def group(break_type = :consistent, delim: nil, indent: @indent)
      lft, rgt =
        case delim
        in nil then ['', '']
        in String | Symbol then [delim, delim]
        in Array then delim.values_at(0, 1).map(&:to_s)
        end

      tokens <<
        case break_type
        in :consistent
          Oppen.begin_consistent(offset: indent)
        in :inconsistent
          Oppen.begin_inconsistent(offset: indent)
        end

      if !lft.empty?
        self.break
        text lft
      end

      yield

      if !rgt.empty?
        self.break
        text rgt
      end

      tokens << Oppen.end
    end

    # An alias for `group(:consistent, ...)`
    def consistent(**kwargs)
      group(:consistent, **kwargs)
    end

    # An alias for `group(:inconsistent, ...)`
    def inconsistent(**kwargs)
      group(:inconsistent, **kwargs)
    end

    # Create a new non-strict {group}.
    #
    # {group}s isolate breaking decisions, and in that sense they're considered
    # strict; e.g. when a breakable is transformed into an actual break, its
    # parent {group} might not get broken if the result could fit on the line.
    #
    # This is not the case with {nest}: if the same breakable was in a {nest}, the
    # {group} containing the {nest} will also be broken.
    #
    # @note indentation cannot happen if there are no breaks in the {nest}.
    #
    # @note a {nest} will not forcibly indent its content if the break type of
    # the enclosing {group} is `:inconsistent`.
    #
    # @param delim [Nil|String|Symbol|Array<Nil, String, Symbol>]
    #   delimiters, to be printed at the start and the end of the group:
    #   - `nil` is always the empty string.
    #   - If it's a Strings or a Symbol, it will be printed at both positions.
    #   - If it's an Array of many items, the first two elements will be used
    #     for the start and end of the group.
    # @param indent [Integer]
    #   indentation.
    #
    # @yield
    #   the block of text in a nest.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.nest(delim: %i[{ }], indent: 2) {
    #     out.text 'a'
    #     out.break
    #     out.text 'b'
    #   }
    #   out.output
    #
    #   # =>
    #   # {
    #   #   a
    #   #   b
    #   # }
    #
    # @return [Nil]
    def nest(delim: nil, indent: @indent)
      lft, rgt =
        case delim
        in nil then ['', '']
        in String | Symbol then [delim, delim]
        in Array then delim.values_at(0, 1).map(&:to_s)
        end

      @current_indent += indent

      if !lft.empty?
        text lft
        self.break
      end

      begin
        yield
      ensure
        @current_indent -= indent
      end

      return if rgt.empty?

      self.break
      text rgt
    end

    # Create a new text element.
    #
    # @param value [String]
    #   the value of the token.
    #
    # @return [Nil]
    def text(value, width: value.length)
      if config.trim_trailing_whitespaces? && value.match(/((?:#{Regexp.escape(whitespace)})+)\z/)
        match = Regexp.last_match(1)
        matched_length = match.length
        if value.length != matched_length
          tokens << Oppen.string(value[0...-matched_length], width: width - matched_length)
        end
        tokens << Oppen.whitespace(match)
      else
        tokens << Oppen.string(value, width: width)
      end
    end

    # Create a new breakable element.
    #
    # @param str               [String]
    #   the value of the token that will be displayed if no new line is needed.
    # @param line_continuation [String]
    #   printed before the line break.
    # @param width             [Integer]
    #   the width of the token.
    #
    # @return [Nil]
    #
    # @see Wadler#break example on `line_continuation`.
    def breakable(str = ' ', line_continuation: '', width: str.length)
      tokens << Oppen.break(str, width: width, line_continuation: line_continuation, offset: current_indent)
    end

    # Create a new break element.
    #
    # @param line_continuation [String]
    #   printed before the line break.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.break
    #   out.text 'b'
    #   out.break line_continuation: '#'
    #   out.text 'c'
    #   puts out.output
    #
    #   # =>
    #   # a
    #   # b#
    #   # c
    #
    # @return [Nil]
    def break(line_continuation: '')
      tokens << Oppen.line_break(line_continuation: line_continuation, offset: current_indent)
    end

    # @!group Helpers

    # Open a consistent group.
    #
    # @param inconsistent [Boolean]
    #   whether the break type of the group should be inconsistent.
    # @param indent       [Integer]
    #   the amount of indentation of the group.
    #
    # @return [Nil]
    #
    # @see Oppen.begin_consistent
    # @see Oppen.begin_inconsistent
    def group_open(inconsistent: false, indent: 0)
      tokens <<
        if inconsistent
          Oppen.begin_inconsistent(offset: indent)
        else
          Oppen.begin_consistent(offset: indent)
        end
    end

    # Close a group.
    #
    # @return [Nil]
    def group_close(_)
      tokens << Oppen.end
    end

    # Open a consistent group and add indent amount.
    #
    # @param indent [Integer]
    #   the amount of indentation of the group.
    #
    # @return [Nil]
    def indent_open(indent: @indent)
      @current_indent += indent
      group_open
    end

    # Close a group and subtract indent.
    #
    # @param indent [Integer]
    #   the amount of indentation of the group.
    #
    # @return [Nil]
    def indent_close(group, indent: @indent)
      @current_indent -= indent
      group_close(group)
    end

    # Open a nest by adding indent.
    #
    # @param indent [Integer]
    #   the amount of indentation of the nest.
    #
    # @return [Nil]
    def nest_open(indent: @indent)
      @current_indent += indent
    end

    # Close a nest by subtracting indent.
    #
    # @param indent [Integer]
    #   the amount of indentation of the nest.
    #
    # @return [Nil]
    def nest_close(indent: @indent)
      @current_indent -= indent
    end

    # @!endgroup
  end
end
