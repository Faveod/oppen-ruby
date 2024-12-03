# frozen_string_literal: true

# Oppen.
module Oppen
  # Token.
  class Token
    # BreakType.
    #
    # FITS => No break is needed (the block fits on the line).
    # INCONSISTENT => New line will be forced only if necessary.
    # CONSISTENT => Each subblock of the block will be placed on a new line.
    module BreakType
      # @return [Integer]
      FITS = 0
      # @return [Integer]
      INCONSISTENT = 1
      # @return [Integer]
      CONSISTENT = 2
    end

    # Default token width
    # @return [Integer]
    def width = 0

    # String Token.
    class String < Token
      # @return [String] String value.
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

    # If a [Token::Break] follows [Token::Whitespace], and an actual break
    # is issued, and `trim_trailing_whitespaces == true`, then all whitespace
    # text will be omitted from the output.
    class Whitespace < ::Oppen::Token::String
    end

    # Break Token.
    class Break < Token
      # @return [String] If a new line is needed display this string before the new line
      attr_reader :line_continuation
      # @return [Integer] Indentation.
      attr_reader :offset
      # @return [String] Break strings.
      attr_reader :str
      # @return [Integer]
      attr_reader :width

      def initialize(str = ' ', width: str.length, line_continuation: '', offset: 0)
        raise ArgumentError, 'line_continuation cannot be nil' if line_continuation.nil?

        @line_continuation = line_continuation
        @offset = offset
        @str = str
        @width = width
        super()
      end

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
        super(LineBreakString.new, line_continuation:, offset:)
      end
    end

    # Begin Token.
    class Begin < Token
      # @return [BreakType]
      attr_reader :break_type
      # @return [Integer] Indentation.
      attr_reader :offset

      def initialize(break_type: BreakType::INCONSISTENT, offset: 2)
        @offset = offset
        @break_type = break_type
        super()
      end

      # The break_type name as a String.
      #
      # @return [String]
      def break_type_name
        case @break_type
        in BreakType::FITS         then 'Oppen::Token::BreakType::FITS'
        in BreakType::INCONSISTENT then 'Oppen::Token::BreakType::INCONSISTENT'
        in BreakType::CONSISTENT   then 'Oppen::Token::BreakType::CONSISTENT'
        end
      end
    end

    # End Token
    class End < Token
      nil
    end

    # EOF Token
    class EOF < Token
      nil
    end
  end
end
