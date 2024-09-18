# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    attr_reader :current_indent
    attr_reader :margin
    attr_reader :new_line
    attr_reader :tokens

    def initialize(margin: 80, new_line: "\n")
      @current_indent = 0
      @margin = margin
      @new_line = new_line
      @tokens = []
    end

    # @return [String]
    def output
      tokens << Oppen.eof
      Oppen.print(tokens:, margin:, new_line:)
    end

    # @param indent [Integer] group indentation
    # @param open_obj [String] group oppening delimiter
    # @param close_obj [String] group closing delimiter
    # @param break_type [Oppen::Token::BreakType] group breaking type
    #
    # @return [Nil]
    def group(indent = 0, open_obj = '', close_obj = '',
              break_type = Oppen::Token::BreakType::CONSISTENT, &)
      if !open_obj.empty?
        self.break
        text(open_obj)
      end

      nest(indent, break_type, &)

      if !close_obj.empty? # rubocop:disable Style/GuardClause
        self.break
        text(close_obj)
      end
    end

    # @param indent [Integer] nest indentation
    # @param break_type [Oppen::Token::BreakType] nest breaking type
    #
    # @return [Nil]
    def nest(indent = 2, break_type = Oppen::Token::BreakType::CONSISTENT, &block)
      previous_indent = current_indent
      @current_indent = indent

      tokens <<
        case break_type
        in Oppen::Token::BreakType::CONSISTENT
          Oppen.begin_consistent(offset: indent)
        in Oppen::Token::BreakType::INCONSISTENT
          Oppen.begin_inconsistent(offset: indent)
        end

      raise LocalJumpError if !block_given?

      block.call

      tokens << Oppen.end
      @current_indent = previous_indent
    end

    # @param value [String]
    #
    # @return [Nil]
    def text(value)
      tokens << Oppen.string(value)
    end

    # @param blank_space [Integer] number of blank spaces before next token
    #
    # @return [Nil]
    def breakable(blank_space = 1)
      tokens << Oppen.break(blank_space:)
    end

    # @param offset [Integer] indentation of the break
    #
    # @return [Nil]
    def break(offset = 0)
      tokens << Oppen.line_break(offset:)
    end
  end
end
