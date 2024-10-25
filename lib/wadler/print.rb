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
    def initialize(config: Config.wadler, space: ' ',
                   new_line: "\n", out: StringIO.new, width: 80)
      @config = config
      @current_indent = 0
      @space = space
      @width = width
      @new_line = new_line
      @out = out
      @tokens = []
    end

    # @return [String]
    def output
      if !tokens.first.is_a? Token::Begin
        tokens.unshift Oppen.begin_consistent(offset: 0)
        tokens << Oppen.end
      end
      if !tokens.last.is_a? Oppen::Token::EOF
        tokens << Oppen.eof
      end
      Oppen.print(tokens:, new_line:, config:, space:, out:, width:)
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
    # @param break_type [Oppen::Token::BreakType] nest breaking type
    #
    # @return [Nil]
    def nest(indent, open_obj = '', close_obj = '',
             break_type = Oppen::Token::BreakType::CONSISTENT)
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
      tokens << Oppen.string(value, width:)
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
    # @param indent [Integer]
    #
    # @return [Nil]
    def group_open(indent: 0)
      tokens << Oppen.begin_consistent(offset: indent)
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
