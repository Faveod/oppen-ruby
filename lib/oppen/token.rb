# frozen_string_literal: true

# Oppen.
module Oppen
  # Token.
  module Token
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

    # String Token.
    class String
      # @return [String] String value.
      attr_reader :value

      def initialize(value)
        @value = value
      end

      # @return [Integer]
      def length
        value.length
      end
    end

    # Break Token.
    class Break
      # @return [String] Break strings.
      attr_reader :str
      # @return [Integer] Indentation.
      attr_reader :offset

      def initialize(str: ' ', offset: 0)
        @str = str
        @offset = offset
      end
    end

    # Distinguished instance of Break which forces a line break.
    class LineBreak < Break
      # Mock string that represents an infinite string to force new line.
      class LineBreakString
        # @return [Integer]
        def length
          999_999
        end
      end

      def initialize(offset: 0)
        super(str: LineBreakString.new, offset:)
      end
    end

    # Begin Token.
    class Begin
      # @return [BreakType]
      attr_reader :break_type
      # @return [Integer] Indentation.
      attr_reader :offset

      def initialize(break_type: BreakType::INCONSISTENT, offset: 2)
        @offset = offset
        @break_type = break_type
      end
    end

    # End Token
    class End
      nil
    end

    # EOF Token
    class EOF
      nil
    end
  end
end
