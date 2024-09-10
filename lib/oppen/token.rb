# frozen_string_literal: true

# Oppen
module Oppen
  # Token used in the oppen algorithm.
  module Token
    module BreakType
      FITS = 0
      INCONSISTENT = 1
      CONSISTENT = 2
    end

    # String Token.
    class String
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def length
        value.length
      end
    end

    # Break Token.
    class Break
      attr_reader :blank_space
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
      attr_reader :break_type
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
