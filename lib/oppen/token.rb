# frozen_string_literal: true

# Oppen module.
module Oppen
  # Token module.
  module Token
    # BreakType enum.
    module BreakType
      # @return [Integer] Type of break mentionned in Oppen's algorithm.
      FITS = 0
      # @return [Integer] Type of break mentionned in Oppen's algorithm.
      INCONSISTENT = 1
      # @return [Integer] Type of break mentionned in Oppen's algorithm.
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
