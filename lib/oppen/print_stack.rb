# frozen_string_literal: true

# Oppen.
module Oppen
  # Class that reprents a stack that builds an output string
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

    # @return [Integer] Current available space (Called index in the original paper).
    attr_reader :space

    def initialize(line_width)
      # Array representing the stack of PrintStackEntries.
      @items = []

      # Current available space (Called index in the original paper).
      @space = line_width

      # Page margin (Called length in the original paper).
      @margin = line_width

      # IO element that builds the output.
      @output = StringIO.new
    end

    # Returns the output of the print stack
    #
    # @return [StringIO]
    def output
      @output.string
    end

    # Core method responsible for building the print stack and the output string.
    #
    # Called Print in the original paper.
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    def print_(token, token_length)
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
    # @see Token::Begin
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    def handle_begin(token, token_length)
      if token_length > @space
        type =
          if token.break_type == Token::BreakType::CONSISTENT
            Token::BreakType::CONSISTENT
          else
            Token::BreakType::INCONSISTENT
          end
        push PrintStackEntry.new @space - token.offset, type
      else
        push PrintStackEntry.new 0, Token::BreakType::FITS
      end
    end

    # Handle End Token.
    # @see Token::End
    #
    # @return [Nil]
    def handle_end
      pop
    end

    # Handle Break Token.
    # @see Token::Break
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    def handle_break(token, token_length)
      block = top
      case block.break_type
      in Token::BreakType::FITS
        @space -= token.blank_space
        indent token.blank_space
      in Token::BreakType::CONSISTENT
        @space = block.offset - token.offset
        print_new_line @margin - @space
      in Token::BreakType::INCONSISTENT
        if token_length > @space
          @space = block.offset - token.offset
          print_new_line @margin - @space
        else
          @space -= token.blank_space
          indent token.blank_space
        end
      end
    end

    # Handle String Token.
    # @see Token::String
    #
    # @param token [Token]
    # @param token_length [Integer]
    #
    # @return [Nil]
    def handle_string(token, token_length)
      if token_length > @space
        raise 'Line too long'
      end

      @space -= token_length
      puts_ token.value
    end

    # Push a PrintStackEntry into the stack.
    #
    # @param print_stack_entry [PrintStackEntry]
    #
    # @return [Nil]
    def push(print_stack_entry)
      @items.append(print_stack_entry)
    end

    # Pop a PrintStackEntry from the stack.
    #
    # @return [PrintStackEntry]
    def pop
      if @items.empty?
        raise 'Popping empty stack'
      end

      @items.pop
    end

    # Get the element at the top of the stack.
    #
    # @return [PrintStackEntry]
    def top
      if @items.empty?
        raise 'Accessing empty stack'
      end

      @items.last
    end

    # Adds a new line to the output.
    #
    # Called PrintNewLine as well in the original paper.
    #
    # @param amount [Integer] indentation amount.
    #
    # @return [Nil]
    def print_new_line(amount)
      puts_ '\n'
      indent amount
    end

    # Writes a string to the output.
    #
    # @param string [String]
    #
    # @return [Nil]
    def puts_(string)
      @output.write(string)
    end

    # Method that adds an identation amount to the output.
    #
    # Called Indent as well in the original paper.
    #
    # @param amount [Integer]
    #
    # @return [Nil]
    def indent(amount)
      puts_ ' ' * amount
    end
  end
end