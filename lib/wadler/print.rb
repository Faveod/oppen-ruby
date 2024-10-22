# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    attr_reader :config
    attr_reader :current_indent
    attr_reader :space
    attr_reader :margin
    attr_reader :new_line
    attr_reader :out
    attr_reader :tokens

    # @param config [Oppen::Config]
    # @param space [String, Proc] could be a String or a callable.
    #   If it's a string, spaces will be generated with the the
    #   lambda `->(n){ n * space }`, where `n` is the number of columns
    #   to indent.
    #   If it's a callable, it will receive `n` and it needs to return
    #   a string.
    # @param margin [Integer]
    # @param new_line [String]
    # @param out [Object] should have a write and string method
    def initialize(config: Config.wadler, space: ' ',
                   margin: 80, new_line: "\n", out: StringIO.new)
      @config = config
      @current_indent = 0
      @space = space
      @margin = margin
      @new_line = new_line
      @out = out
      @tokens = []
    end

    # @return [String]
    def output
      if !tokens.last.is_a? Oppen::Token::EOF
        tokens << Oppen.eof
      end
      Oppen.print(tokens:, margin:, new_line:, config:, space:, out:)
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
  end
end
