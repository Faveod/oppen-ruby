# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    # To customize the printer's behavior.
    attr_reader :config
    # The current indentation amount.
    attr_reader :current_indent
    # The new line String.
    attr_reader :new_line
    # The output string buffer. It should have a `write` and `string` methods.
    attr_reader :out
    # The indentator.
    attr_reader :space
    # The tokens list that is being built.
    attr_reader :tokens
    # The whitespace character. Used to trim trailing whitespaces.
    attr_reader :whitespace
    # Maximum line width desired.
    attr_reader :width

    # @param config     [Config]       to customize the printer's behavior.
    # @param new_line   [String]       the new line String.
    # @param out        [Object]       the output string buffer. It should have a `write` and `string` methods.
    # @param space      [String, Proc] indentation string or a code that generates the indentation string.
    #   If it's a string, spaces will be generated with lambda `->(n){ space * n }`,
    #   where `n` is the number of columns to indent. If it's a callable, it
    #   will receive `n` and it needs to return a string.
    # @param whitespace [String]       the whitespace character. Used to trim trailing whitespaces.
    # @param width      [Integer]      maximum line width desired.
    # @see Token::Whitespace
    def initialize(config: Config.wadler, new_line: "\n",
                   out: StringIO.new, space: ' ',
                   whitespace: ' ', width: 80)
      @config = config
      @current_indent = 0
      @space = space
      @width = width
      @new_line = new_line
      @out = out
      @tokens = []
      @whitespace = whitespace
    end

    # Add missing Begin, End or EOF tokens.
    #
    # @return [Nil]
    def add_missing_begin_and_end
      if !tokens.first.is_a? Token::Begin
        tokens.unshift Oppen.begin_consistent(offset: 0)
        tokens << Oppen.end
      end
      tokens << Oppen.eof if !tokens.last.is_a?(Oppen::Token::EOF)
    end

    # Generate the output string of the built list of tokens using Oppen's
    # pretty printing algorithm.
    #
    # @return [String]
    def output
      add_missing_begin_and_end
      Oppen.print(tokens:, new_line:, config:, space:, out:, width:)
    end

    # Generate the the list of Wadler commands needed to build the built list of
    # tokens.
    #
    # @return [String]
    def show_print_commands(**)
      add_missing_begin_and_end
      Oppen.tokens_to_wadler(tokens, **)
    end

    # Create a new group.
    #
    # @param indent     [Integer]          group indentation.
    # @param open_obj   [String]           group opening delimiter.
    # @param close_obj  [String]           group closing delimiter.
    # @param break_type [Token::BreakType] group breaking type.
    #
    # @yield the block of text in a group.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.group(2, '{', '}') {
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
    # @example consistent
    #   out = Oppen::Wadler.new
    #   out.group(0, '', '', :consistent) {
    #     out.text 'a'
    #     out.break
    #     out.text 'b'
    #     out.breakable
    #     out.text 'c'
    #   }
    #   out.output
    #
    #   # =>
    #   # a
    #   # b
    #   # c
    #
    # @example inconsistent
    #   out = Oppen::Wadler.new
    #   out.group(0, '', '', :inconsistent) {
    #     out.text 'a'
    #     out.break
    #     out.text 'b'
    #     out.breakable
    #     out.text 'c'
    #   }
    #   out.output
    #
    #   # =>
    #   # a
    #   # b c
    #
    # @return [Nil]
    #
    # @see Oppen.begin_consistent
    # @see Oppen.begin_inconsistent
    def group(indent = 0, open_obj = '', close_obj = '',
              break_type = :consistent)
      raise ArgumentError, "#{open_obj.nil? ? 'open_obj' : 'close_obj'} cannot be nil" \
        if open_obj.nil? || close_obj.nil?

      tokens <<
        case break_type
        in :consistent
          Oppen.begin_consistent(offset: indent)
        in :inconsistent
          Oppen.begin_inconsistent(offset: indent)
        end

      if !open_obj.empty?
        self.break
        text(open_obj)
      end

      yield

      if !close_obj.empty?
        self.break
        text(close_obj)
      end

      tokens << Oppen.end
    end

    # Create a new nest.
    #
    # @param indent    [Integer] nest indentation.
    # @param open_obj  [String]  nest opening delimiter.
    # @param close_obj [String]  nest closing delimiter.
    #
    # @yield the block of text in a nest.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.nest(2, '{', '}') {
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
    def nest(indent, open_obj = '', close_obj = '')
      raise ArgumentError, "#{open_obj.nil? ? 'open_obj' : 'close_obj'} cannot be nil" \
        if open_obj.nil? || close_obj.nil?

      @current_indent += indent

      if !open_obj.empty?
        text(open_obj)
        self.break
      end

      begin
        yield
      ensure
        @current_indent -= indent
      end

      return if close_obj.empty?

      self.break
      text(close_obj)
    end

    # Create a new text element.
    #
    # @param value [String] the value of the token.
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
        tokens << Oppen.string(value, width:)
      end
    end

    # Create a new breakable element.
    #
    # @param str               [String]  the value of the token that will be displayed if no new line is needed.
    # @param line_continuation [String]  printed before the line break.
    # @param width             [Integer] the width of the token.
    #
    # @return [Nil]
    #
    # @see Wadler#break for an example on `line_continuation`.
    def breakable(str = ' ', line_continuation: '', width: str.length)
      tokens << Oppen.break(str, width:, line_continuation:, offset: current_indent)
    end

    # Create a new break element.
    #
    # @param line_continuation [String] printed before the line break.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.break
    #   out.text 'b'
    #   out.break line_continuation: '#'
    #   out.text 'c'
    #   out.output
    #
    #   # =>
    #   # a
    #   # b#
    #   # c
    #
    # @return [Nil]
    def break(line_continuation: '')
      tokens << Oppen.line_break(line_continuation:, offset: current_indent)
    end

    # @!group Helpers

    # Set a base indenetaion level for the printer.
    #
    # @param indent [Integer] the amount of indentation.
    #
    # @return [Nil]
    def base_indent(indent = 0)
      @current_indent = indent if !indent.nil?
    end

    # Open a consistent group.
    #
    # @param inconsistent [Boolean] whether the break type of the group should be inconsistent.
    # @param indent       [Integer] the amount of indentation of the group.
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
    # @param indent [Integer] the amount of indentation of the group.
    #
    # @return [Nil]
    def indent_open(indent)
      @current_indent += indent
      group_open
    end

    # Close a group and subtract indent.
    #
    # @param indent [Integer] the amount of indentation of the group.
    #
    # @return [Nil]
    def indent_close(group, indent)
      @current_indent -= indent
      group_close(group)
    end

    # Open a nest by adding indent.
    #
    # @param indent [Integer] the amount of indentation of the nest.
    #
    # @return [Nil]
    def nest_open(indent)
      @current_indent += indent
    end

    # Close a nest by subtracting indent.
    #
    # @param indent [Integer] the amount of indentation of the nest.
    #
    # @return [Nil]
    def nest_close(indent)
      @current_indent -= indent
    end

    # @!endgroup
  end
end
