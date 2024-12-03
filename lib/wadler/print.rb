# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    attr_reader :config
    attr_reader :current_indent
    attr_reader :space
    attr_reader :new_line
    attr_reader :out
    attr_reader :tokens
    attr_reader :whitespace
    attr_reader :width

    # @param config [Oppen::Config]
    # @param space [String, Proc] could be a String or a callable.
    #   If it's a string, spaces will be generated with the the
    #   lambda `->(n){ n * space }`, where `n` is the number of columns
    #   to indent.
    #   If it's a callable, it will receive `n` and it needs to return
    #   a string.
    # @param new_line [String]
    # @param out [Object] should have a write and string method
    # @param width [Integer]
    # @param whitespace [String] the whitespace character. Used to trim trailing whitespaces.
    # @see Token::Whitespace
    def initialize(config: Config.wadler, space: ' ',
                   new_line: "\n", out: StringIO.new,
                   width: 80, whitespace: ' ')
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
    # @return [Nil]
    def add_missing_begin_and_end
      if !tokens.first.is_a? Token::Begin
        tokens.unshift Oppen.begin_consistent(offset: 0)
        tokens << Oppen.end
      end
      tokens << Oppen.eof if !tokens.last.is_a?(Oppen::Token::EOF)
    end

    # Generate the output string of the built list of tokens
    # using Oppen's pretty printing algorithm.
    #
    # @return [String]
    def output
      add_missing_begin_and_end
      Oppen.print(tokens:, new_line:, config:, space:, out:, width:)
    end

    # Generate the the list of Wadler commands needed to build the built
    # list of tokens.
    #
    # @return [String]
    def show_print_commands(**)
      add_missing_begin_and_end
      Oppen.tokens_to_wadler(tokens, **)
    end

    # @param indent [Integer] group indentation
    # @param open_obj [String] group opening delimiter
    # @param close_obj [String] group closing delimiter
    # @param break_type [Oppen::Token::BreakType] group breaking type
    #
    # @yield the block of text in a group
    #
    # @return [Nil]
    def group(indent = 0, open_obj = '', close_obj = '',
              break_type = Oppen::Token::BreakType::CONSISTENT)
      raise ArgumentError, "#{open_obj.nil? ? 'open_obj' : 'close_obj'} cannot be nil" \
        if open_obj.nil? || close_obj.nil?

      tokens <<
        case break_type
        in Oppen::Token::BreakType::CONSISTENT
          Oppen.begin_consistent(offset: indent)
        in Oppen::Token::BreakType::INCONSISTENT
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

    # @param indent [Integer] nest indentation
    # @param open_obj [String] nest opening delimiter
    # @param close_obj [String] nest closing delimiter
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

    # @param value [String]
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

    # @param str [String]
    # @param line_continuation [String] If a new line is needed display this string before the new line
    #
    # @return [Nil]
    def breakable(str = ' ', width: str.length, line_continuation: '')
      tokens << Oppen.break(str, width:, line_continuation:, offset: current_indent)
    end

    # @param line_continuation [String] If a new line is needed display this string before the new line
    #
    # @return [Nil]
    def break(line_continuation: '')
      tokens << Oppen.line_break(line_continuation:, offset: current_indent)
    end

    # @!group Helpers

    # Set a base indenetaion level to the printer.
    #
    # @param indent [Integer]
    #
    # @return [Nil]
    def base_indent(indent = 0)
      @current_indent = indent if !indent.nil?
    end

    # Open a consistent group.
    #
    # @param inconsistent [Boolean]
    # @param indent       [Integer]
    #
    # @return [Nil]
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

    # Open a consistent group with indent.
    #
    # @param indent [Integer]
    #
    # @return [Nil]
    def indent_open(indent)
      @current_indent += indent
      group_open
    end

    # Close a group with indent.
    #
    # @param indent [Integer]
    #
    # @return [Nil]
    def indent_close(group, indent)
      @current_indent -= indent
      group_close(group)
    end

    # Open a nest by indent.
    #
    # @param indent [Integer]
    #
    # @return [Nil]
    def nest_open(indent)
      @current_indent += indent
    end

    # Close a nest by indent.
    #
    # @param indent [Integer]
    #
    # @return [Nil]
    def nest_close(indent)
      @current_indent -= indent
    end

    # @!endgroup
  end
end
