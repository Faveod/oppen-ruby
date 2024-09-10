# frozen_string_literal: true

require 'stringio'

require_relative 'scan_stack'
require_relative 'print_stack'

# Oppen.
module Oppen
  # PrettyPrinter class responsible for scanning tokens and passing
  # them to the printer.
  class PrettyPrinter
    # Initializes the needed class attributes.
    #
    # Called PrettyPrintInit in the original paper.
    #
    # @param line_width [Integer]  maximum line width desired.
    def initialize(line_width)
      # Maximum size if the stacks
      n = 3 * line_width

      # Token buffer, initially filled with nil.
      #
      # Called token in the orginal paper.
      @tokens = Array.new n

      # Size buffer, initially filled with nil.
      #
      # Called size as well in the orginal paper.
      @size = Array.new n

      # Potential breaking positions.
      #
      # Called scanStack as well in the original paper.
      @scan_stack = ScanStack.new n

      # Total number of spaces needed to print from start of buffer to left/right.
      #
      # Called leftTotal and rightTotl as well in the original paper.
      @left_total = @right_total = 1

      # Ring buffer left and right indexes.
      #
      # Called left and right as well in the original paper.
      @left = @right = 0

      # Called printStack as well in the original paper.
      @print_stack = PrintStack.new line_width
    end

    # @return [StringIO]
    def output
      @print_stack.output
    end

    # Core function of the algorithm responsible for populating the scan and print stack.
    #
    # Called PrettyPrint as well in the original paper.
    #
    # @param token [Token]
    #
    # @return [Nil]
    def pretty_print(token)
      case token
      in Token::EOF
        handle_eof
      in Token::Begin
        handle_begin token
      in Token::End
        handle_end token
      in Token::Break
        handle_break token
      in Token::String
        handle_string token
      end
    end

    # Handle EOF Token.
    # @see Token::EOF
    #
    # @return [Nil]
    def handle_eof
      if !@scan_stack.empty?
        check_stack 0
        advance_left @tokens[@left], @size[@left]
      end
      @print_stack.indent 0
    end

    # Handle Begin Token.
    # @see Token::Begin
    #
    # @return [Nil]
    def handle_begin(token)
      if @scan_stack.empty?
        @left_total = @right_total = 1
        @left = @right = 0
      else
        advance_right
      end
      @tokens[@right] = token
      @size[@right] = -@right_total
      @scan_stack.push @right
    end

    # Handle End Token.
    # @see Token::End
    #
    # @return [Nil]
    def handle_end(token)
      if @scan_stack.empty?
        @print_stack.print_ token, 0
      else
        advance_right
        @tokens[@right] = token
        @size[@right] = -1
        @scan_stack.push @right
      end
    end

    # Handle Break Token.
    # @see Token::Break
    #
    # @return [Nil]
    def handle_break(token)
      if @scan_stack.empty?
        @left_total = @right_total = 1
        @left = @right = 0
      else
        advance_right
      end
      check_stack 0
      @scan_stack.push @right
      @tokens[@right] = token
      @size[@right] = -@right_total
      @right_total += token.blank_space
    end

    # Handle String Token.
    # @see Token::String
    #
    # @return [Nil]
    def handle_string(token)
      if @scan_stack.empty?
        @print_stack.print_ token, token.length
      else
        advance_right
        @tokens[@right] = token
        @size[@right] = token.length
        @right_total += token.length
        check_stream
      end
    end

    # Method that flushes the input if possible.
    #
    # Called CheckStream as well in the original paper.
    #
    # @return [Nil]
    def check_stream
      return if @right_total - @left_total <= @print_stack.space

      if !@scan_stack.empty? && @left == @scan_stack.bottom
        @size[@scan_stack.pop_bottom] = Float::INFINITY
      end
      advance_left @tokens[@left], @size[@left]
      return if @left == @right

      check_stream
    end

    # Method responsible for advancing the `right` pointer.
    #
    # Called AdvanceRight as well in the original paper.
    #
    # @return [Nil]
    def advance_right
      @right = (@right + 1) % @scan_stack.length
      return if @right != @left

      raise 'Token queue full'
    end

    # Method responsible for advancing the `left` pointer as well as
    # letting the print stack print some of the tokens it contains.
    #
    # Called AdvanceLeft as well in the original paper.
    #
    # @return [Nil]
    def advance_left(token, token_length)
      return if token_length.negative?

      @print_stack.print_ token, token_length

      case token
      when Token::Break
        @left_total += token.blank_space
      when Token::String
        @left_total += token_length
      end

      return if @left == @right

      @left = (@left + 1) % @scan_stack.length
      advance_left @tokens[@left], @size[@left]
    end

    # Method responsible for updating the size buffer taking into
    # account the length of the current group.
    #
    # Called CheckStack as well in the original paper.
    #
    # @param depth [Integer] depth of the group
    #
    # @return [Nil]
    def check_stack(depth)
      return if @scan_stack.empty?

      x = @scan_stack.top
      case @tokens[x]
      when Token::Begin
        if depth.positive?
          @size[@scan_stack.pop] = @size[x] + @right_total
          check_stack depth - 1
        end
      when Token::End
        @size[@scan_stack.pop] = 1
        check_stack depth + 1
      else
        @size[@scan_stack.pop] = @size[x] + @right_total
        if depth.positive?
          check_stack depth
        end
      end
    end
  end
end
