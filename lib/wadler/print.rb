# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    attr_reader :config
    attr_reader :current_indent
    attr_reader :margin
    attr_reader :new_line
    attr_reader :tokens

    # @param config [Oppen::Config]
    # @param margin [Integer]
    # @param new_line [String]
    def initialize(config: Config.wadler, margin: 80, new_line: "\n")
      @config = config
      @current_indent = 0
      @margin = margin
      @new_line = new_line
      @tokens = []
    end

    # @return [String]
    def output
      if !tokens.last.is_a? Oppen::Token::EOF
        tokens << Oppen.eof
      end
      Oppen.print(tokens:, margin:, new_line:, config:)
    end

    # @param indent [Integer] group indentation
    # @param open_obj [String] group oppening delimiter
    # @param close_obj [String] group closing delimiter
    # @param break_type [Oppen::Token::BreakType] group breaking type
    #
    # @yield the block of text in a group
    #
    # @return [Nil]
    def group(indent = 0, open_obj = '', close_obj = '',
              break_type = Oppen::Token::BreakType::CONSISTENT, &)
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

      nest(indent, break_type, &)

      if !close_obj.empty?
        self.break
        text(close_obj)
      end

      tokens << Oppen.end
    end

    # @param indent [Integer] nest indentation
    # @param break_type [Oppen::Token::BreakType] nest breaking type
    #
    # @return [Nil]
    def nest(indent, break_type = Oppen::Token::BreakType::CONSISTENT, &block)
      @current_indent += indent

      raise LocalJumpError if !block_given?

      block.call
    ensure
      @current_indent -= indent
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
      tokens << Oppen.break(blank_space:, offset: current_indent)
    end

    # @param offset [Integer] indentation of the break
    #
    # @return [Nil]
    def break(offset = 0)
      tokens << Oppen.line_break(offset:)
    end
  end
end
