# frozen_string_literal: true

# Oppen.
module Oppen
  # Class that represents a stack that builds an output string
  # using the values of the tokens that were pushed into it.
  class PrintStack
    # Class that represents an item in the print stack.
    class PrintStackEntry
      # @return [Integer] Indentation level.
      attr_reader :offset
      # @return [Token::BreakType] (Called break in the original paper).
      attr_reader :break_type

      def initialize(offset, break_type)
        @offset = offset
        @break_type = break_type
      end
    end

    # IO element that builds the output.
    attr_reader :buffer

    # Array representing the stack of PrintStackEntries.
    attr_reader :items

    # Delimiter between lines in output
    attr_reader :new_line

    # Page margin (Called length in the original paper).
    attr_reader :margin

    # Current available space (Called index in the original paper).
    #
    # @return [Integer] Current available space (Called index in the original paper).
    attr_reader :space

    def initialize(margin, new_line)
      @buffer = StringIO.new
      @items = []
      @new_line = new_line
      @margin = margin
      @space = margin
    end

    # Returns the output of the print stack
    #
    # @return [StringIO]
    def output
      buffer.string
    end

    # Core method responsible for building the print stack and the output string.
    #
    # @note Called Print in the original paper.
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    def print(token, token_length)
      case token
      in Token::Begin
        handle_begin token, token_length
      in Token::End
        handle_end
      in Token::Break
        handle_break token, token_length
      in Token::String
        handle_string token, token_length
      end
    end

    # Handle Begin Token.
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    #
    # @see Token::Begin
    def handle_begin(token, token_length)
      if token_length > space
        type =
          if token.break_type == Token::BreakType::CONSISTENT
            Token::BreakType::CONSISTENT
          else
            Token::BreakType::INCONSISTENT
          end
        push PrintStackEntry.new space - token.offset, type
      else
        push PrintStackEntry.new 0, Token::BreakType::FITS
      end
    end

    # Handle End Token.
    #
    # @return [Nil]
    #
    # @see Token::End
    def handle_end
      pop
    end

    # Handle Break Token.
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    #
    # @see Token::Break
    def handle_break(token, token_length)
      block = top
      case block.break_type
      in Token::BreakType::FITS
        @space -= token.blank_space
        indent token.blank_space
      in Token::BreakType::CONSISTENT
        @space = block.offset - token.offset
        print_new_line margin - space
      in Token::BreakType::INCONSISTENT
        if token_length > space
          @space = block.offset - token.offset
          print_new_line margin - space
        else
          @space -= token.blank_space
          indent token.blank_space
        end
      end
    end

    # Handle String Token.
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    #
    # @see Token::String
    def handle_string(token, token_length)
      @space = [0, space - token_length].max
      write token.value
    end

    # Push a PrintStackEntry into the stack.
    #
    # @param print_stack_entry [PrintStackEntry]
    #
    # @return [Nil]
    def push(print_stack_entry)
      items.append(print_stack_entry)
    end

    # Pop a PrintStackEntry from the stack.
    #
    # @return [PrintStackEntry]
    def pop
      if items.empty?
        raise 'Popping empty stack'
      end

      items.pop
    end

    # Get the element at the top of the stack.
    #
    # @return [PrintStackEntry]
    def top
      if items.empty?
        raise 'Accessing empty stack'
      end

      items.last
    end

    # Add a new line to the output.
    #
    # @note Called PrintNewLine as well in the original paper.
    #
    # @param amount [Integer] indentation amount.
    #
    # @return [Nil]
    def print_new_line(amount)
      write new_line
      indent amount
    end

    # Write a string to the output.
    #
    # @param string [String]
    #
    # @return [Nil]
    def write(string)
      buffer.write(string)
    end

    # Add indentation by `amount`.
    #
    # @note Called Indent as well in the original paper.
    #
    # @param amount [Integer]
    #
    # @return [Nil]
    def indent(amount)
      write ' ' * amount
    end
  end
end
