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
      # @return [Integer] Number of blank spaces.
      attr_reader :blank_space
      # @return [Integer] Indentation.
      attr_reader :offset

      def initialize(blank_space = 1, offset = 0)
        @blank_space = blank_space
        @offset = offset
      end
    end

    # Distinguished instance of Break which forces a line break.
    class LineBreak < Break
      def initialize(offset = 0)
        super(blank_space: 9999, offset:)
      end
    end

    # Begin Token.
    class Begin
      # @return [BreakType]
      attr_reader :break_type
      # @return [Integer] Indentation.
      attr_reader :offset

      def initialize(break_type = BreakType::INCONSISTENT, offset = 2)
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
