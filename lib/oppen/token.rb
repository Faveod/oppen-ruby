# frozen_string_literal: true

# Oppen.
module Oppen
  # Token.
  class Token
    # Default token width.
    #
    # @return [Integer]
    def width = 0

    # String Token.
    class String < Token
      # @return [String]
      attr_reader :value
      # @return [Integer]
      attr_reader :width

      def initialize(value, width: value.length)
        @value = value
        @width = width
        super()
      end

      # @return [String]
      def to_s = value
    end

    # This token is not part of Oppen's original work. We introduced it to
    # handle trailing whitespaces.
    #
    # When the config flag `trim_trailing_whitespaces == true`, and a new line
    # is needed, all the {Token::Whitespace} figuring after the last {Token::String}
    # will be be skipped.
    class Whitespace < ::Oppen::Token::String
    end

    # Break Token.
    class Break < Token
      # @return [String]
      #   If a new line is needed, display this string before the new line.
      #
      # @see Wadler#break example on `line_continuation`.
      attr_reader :line_continuation
      # @return [Integer] Indentation.
      attr_reader :offset
      # @return [String] Break strings.
      attr_reader :str
      # @return [Integer]
      attr_reader :width

      def initialize(str = ' ', line_continuation: '', offset: 0, width: str.length)
        raise ArgumentError, 'line_continuation cannot be nil' if line_continuation.nil?

        @line_continuation = line_continuation
        @offset = offset
        @str = str
        @width = width
        super()
      end

      # Convert token to String.
      #
      # @return [String]
      def to_s = str
    end

    # Distinguished instance of Break which forces a line break.
    class LineBreak < Break
      # Mock string that represents an infinite string to force new line.
      class LineBreakString
        # @return [Integer]
        def length = 999_999
      end

      def initialize(line_continuation: '', offset: 0)
        super(LineBreakString.new, line_continuation: line_continuation, offset: offset)
      end
    end

    # Begin Token.
    class Begin < Token
      # @return [BreakType]
      attr_reader :break_type
      # @return [Integer]
      attr_reader :offset

      def initialize(break_type: :inconsistent, offset: 2)
        @offset = offset
        @break_type = break_type
        super()
      end
    end

    # End Token.
    class End < Token
      nil
    end

    # The EOF token can be interpreted as an output flush operation.
    #
    # @note Multiple {Token::EOF} tokens can be present in the same list of tokens.
    #
    # @example
    #   tokens = [
    #     Oppen::Token::Begin.new,
    #     Oppen::Token::String.new('XXXXXXXXXX'),
    #     Oppen::Token::End.new,
    #     Oppen::Token::EOF.new,
    #     Oppen::Token::Begin.new,
    #     Oppen::Token::String.new('YYYYYYYYYY'),
    #     Oppen::Token::End.new,
    #   ]
    #   Oppen.print tokens:
    #
    #   # =>
    #   # XXXXXXXXXX
    #
    #   tokens = [
    #     Oppen::Token::Begin.new,
    #     Oppen::Token::String.new('XXXXXXXXXX'),
    #     Oppen::Token::End.new,
    #     Oppen::Token::Begin.new,
    #     Oppen::Token::String.new('YYYYYYYYYY'),
    #     Oppen::Token::End.new,
    #     Oppen::Token::EOF.new,
    #   ]
    #   Oppen.print tokens:
    #
    #   # =>
    #   # XXXXXXXXXXYYYYYYYYYY
    class EOF < Token
      nil
    end
  end
end
