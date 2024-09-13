# frozen_string_literal: true

require 'stringio'

require_relative 'scan_stack'
require_relative 'print_stack'

# Oppen.
module Oppen
  # PrettyPrinter class responsible for scanning tokens and passing
  # them to the printer.
  class PrettyPrinter
    # Ring buffer left indexe.
    #
    # @note Called left as well in the original paper.
    attr_reader :left

    # Total number of spaces needed to print from start of buffer to the left.
    #
    # @note Called leftTotal as well in the original paper.
    attr_reader :left_total

    # @note Called printStack as well in the original paper.
    attr_reader :print_stack

    # Ring buffer right indexe.
    #
    # @note Called right as well in the original paper.
    attr_reader :right

    # Total number of spaces needed to print from start of buffer to the right.
    #
    # @note Called leftTotal as well in the original paper.
    attr_reader :right_total

    # Potential breaking positions.
    #
    # @note Called scanStack as well in the original paper.
    attr_reader :scan_stack

    # Size buffer, initially filled with nil.
    #
    # @note Called size as well in the original paper.
    attr_reader :size

    # Token buffer, initially filled with nil.
    #
    # @note Called token in the original paper.
    attr_reader :tokens

    # @note Called PrettyPrintInit in the original paper.
    #
    # @param line_width [Integer]  maximum line width desired.
    # @param line_delimiter [String] the delimiter between lines
    def initialize(line_width, line_delimiter)
      # Maximum size if the stacks
      n = 3 * line_width

      @left = 0
      @left_total = 1
      @print_stack = PrintStack.new line_width, line_delimiter
      @right = 0
      @right_total = 1
      @scan_stack = ScanStack.new n
      @size = Array.new n
      @tokens = Array.new n
    end

    # @return [StringIO]
    def output
      print_stack.output
    end

    # Core function of the algorithm responsible for populating the scan and print stack.
    #
    # @note Called PrettyPrint as well in the original paper.
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
    #
    # @return [Nil]
    #
    # @see Token::EOF
    def handle_eof
      if !scan_stack.empty?
        check_stack 0
        advance_left tokens[left], size[left]
      end
      print_stack.indent 0
    end

    # Handle Begin Token.
    #
    # @return [Nil]
    #
    # @see Token::Begin
    def handle_begin(token)
      if scan_stack.empty?
        @left = 0
        @left_total = 1
        @right = 0
        @right_total = 1
      else
        advance_right
      end
      tokens[right] = token
      size[right] = -right_total
      scan_stack.push right
    end

    # Handle End Token.
    #
    # @return [Nil]
    #
    # @see Token::End
    def handle_end(token)
      if scan_stack.empty?
        print_stack.print token, 0
      else
        advance_right
        tokens[right] = token
        size[right] = -1
        scan_stack.push right
      end
    end

    # Handle Break Token.
    #
    # @return [Nil]
    #
    # @see Token::Break
    def handle_break(token)
      if scan_stack.empty?
        @left = 0
        @left_total = 1
        @right = 0
        @right_total = 1
      else
        advance_right
      end
      check_stack 0
      scan_stack.push right
      tokens[right] = token
      size[right] = -right_total
      @right_total += token.blank_space
    end

    # Handle String Token.
    #
    # @return [Nil]
    #
    # @see Token::String
    def handle_string(token)
      if scan_stack.empty?
        print_stack.print token, token.length
      else
        advance_right
        tokens[right] = token
        size[right] = token.length
        @right_total += token.length
        check_stream
      end
    end

    # Flushes the input if possible.
    #
    # @note Called CheckStream as well in the original paper.
    #
    # @return [Nil]
    def check_stream
      return if right_total - left_total <= print_stack.space

      if !scan_stack.empty? && left == scan_stack.bottom
        size[scan_stack.pop_bottom] = Float::INFINITY
      end
      advance_left tokens[left], size[left]
      return if left == right

      check_stream
    end

    # Advances the `right` pointer.
    #
    # @note Called AdvanceRight as well in the original paper.
    #
    # @return [Nil]
    def advance_right
      @right = (right + 1) % scan_stack.length
      return if right != left

      raise 'Token queue full'
    end

    # Advances the `left` pointer and lets the print stack
    # print some of the tokens it contains.
    #
    # @note Called AdvanceLeft as well in the original paper.
    #
    # @return [Nil]
    def advance_left(token, token_length)
      return if token_length.negative?

      print_stack.print token, token_length

      case token
      when Token::Break
        @left_total += token.blank_space
      when Token::String
        @left_total += token_length
      end

      return if left == right

      @left = (left + 1) % scan_stack.length
      advance_left tokens[left], size[left]
    end

    # Updates the size buffer taking into
    # account the length of the current group.
    #
    # @note Called CheckStack as well in the original paper.
    #
    # @param depth [Integer] depth of the group
    #
    # @return [Nil]
    def check_stack(depth) # rubocop:disable Metrics/AbcSize
      return if scan_stack.empty?

      x = scan_stack.top
      case tokens[x]
      when Token::Begin
        if depth.positive?
          size[scan_stack.pop] = size[x] + right_total
          check_stack depth - 1
        end
      when Token::End
        size[scan_stack.pop] = 1
        check_stack depth + 1
      else
        size[scan_stack.pop] = size[x] + right_total
        if depth.positive?
          check_stack depth
        end
      end
    end
  end
end
