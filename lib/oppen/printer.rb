# frozen_string_literal: true

require 'stringio'

require_relative 'mixins'
require_relative 'print_stack'
require_relative 'scan_stack'

# Oppen.
module Oppen
  # Oppen pretty-printer.
  class Printer
    extend Mixins

    # The printer's configuration, altering its behavior.
    #
    # @return [Config]
    attr_reader :config
    # Ring buffer's left index.
    #
    # @note Called `left` as well in the original paper.
    #
    # @return [Integer]
    attr_reader :left
    # Number of spaces needed to print from start of buffer to left.
    #
    # @note Called `leftTotal` as well in the original paper.
    #
    # @return [Integer]
    attr_reader :left_total
    # A stack of {Token}s; builds the the final output.
    #
    # @note Called `printStack` as well in the original paper.
    #
    # @return [PrintStack]
    attr_reader :print_stack
    # Ring buffer's right index.
    #
    # @note Called `right` as well in the original paper.
    #
    # @return [Integer]
    attr_reader :right
    # Number of spaces needed to print from start of buffer to right.
    #
    # @note Called `leftTotal` as well in the original paper.
    #
    # @return [Integer]
    attr_reader :right_total
    # Potential breaking positions.
    #
    # @note Called `scanStack` as well in the original paper.
    #
    # @return [ScanStack]
    attr_reader :scan_stack
    # Size buffer, initially filled with nil.
    #
    # @note Called `size` as well in the original paper.
    #
    # @return [Integer]
    attr_reader :size
    # Token buffer, initially filled with nil.
    #
    # @note Called `token` in the original paper.
    #
    # @return [Array<Tokens>]
    attr_reader :tokens

    # @note Called `PrettyPrintInit` in the original paper.
    #
    # @param config   [Config]
    #   to customize the printer's behavior.
    # @param new_line [String]
    #   the delimiter between lines.
    # @param space    [String, Proc]
    #   indentation string or a string generator.
    #   - If a `String`, spaces will be generated with the the lambda
    #     `->(n){ space * n }`, where `n` is the number of columns to indent.
    #   - If a `Proc`, it will receive `n` and it needs to return a `String`.
    # @param width    [Integer]
    #   maximum line width desired.
    # @param out      [Object]
    #   the output string buffer. It should have both `write` and `string`
    #   methods.
    def initialize(width, new_line, config = Config.oppen,
                   space = ' ', out = StringIO.new)
      # Maximum size if the stacks
      n = 3 * width

      @config = config
      @last_whitespaces_width = 0 # Accumulates the width of the last Whitespace tokens encountered.
      @left = 0
      @left_total = 1
      @print_stack = PrintStack.new width, new_line, config, space, out
      @right = 0
      @right_total = 1
      @scan_stack = ScanStack.new n, config
      @size = Array.new n
      @tokens = Array.new n
    end

    # The final pretty-printed output.
    #
    # @return [String]
    #   the output of the print stack.
    def output = print_stack.output

    # Core function of the algorithm responsible for populating the {ScanStack}
    # and {PrintStack}.
    #
    # @note Called `PrettyPrint` as well in the original paper.
    #
    # @param token [Token]
    #
    # @return [Nil]
    def print(token)
      case token
      in Token::EOF
        handle_eof
      in Token::Begin
        handle_begin token
      in Token::End
        handle_end token
      in Token::Break
        handle_break token
      in Token::Whitespace
        @last_whitespaces_width += token.width
        handle_string token
      in Token::String
        @last_whitespaces_width = 0
        handle_string token
      end
    end

    # Handle {Token::EOF}.
    #
    # @return [Nil]
    def handle_eof
      if !scan_stack.empty?
        check_stack 0
        advance_left tokens[left], size[left]
      end
      print_stack.indent 0
    end

    # Handle {Token::Begin}.
    #
    # @param token [Token::Begin]
    #
    # @return [Nil]
    def handle_begin(token)
      if scan_stack.empty?
        @left = 0
        @left_total = 1
        @right = 0
        @right_total = 1

        # config.trim_trailing_whitespaces.
        @tokens[-1] = nil
      else
        advance_right
      end
      tokens[right] = token
      size[right] = -right_total
      scan_stack.push right
    end

    # Handle {Token::End}.
    #
    # @param token [Token::End]
    #
    # @return [Nil]
    def handle_end(token)
      if scan_stack.empty?
        print_stack.print token, 0
      else
        advance_right
        tokens[right] = token
        size[right] = -1
        scan_stack.push right
        if config&.eager_print? &&
           (!scan_stack.empty? && right_total - left_total < print_stack.space)
          check_stack 0
          advance_left tokens[left], size[left]
        end
      end
    end

    # Handle {Token::Break}.
    #
    # @param token [Token::Break]
    #
    # @return [Nil]
    def handle_break(token)
      if scan_stack.empty?
        @left = 0
        @left_total = 1
        @right = 0
        @right_total = 1

        # config.trim_trailing_whitespaces.
        tokens[-1] = nil
        print_stack.erase @last_whitespaces_width
        @last_whitespaces_width = 0
      else
        advance_right
      end
      check_stack 0
      scan_stack.push right
      tokens[right] = token
      size[right] = -right_total
      @right_total += token.width
    end

    # Handle {Token::String}.
    #
    # @param token [Token::String]
    #
    # @return [Nil]
    def handle_string(token)
      if scan_stack.empty?
        print_stack.print token, token.width
      else
        advance_right
        tokens[right] = token
        size[right] = token.width
        @right_total += token.width
        check_stream if @last_whitespaces_width.zero?
      end
    end

    # Flushes the input if possible.
    #
    # @note Called `CheckStream` as well in the original paper.
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

    # Advances the {#right} pointer.
    #
    # @note Called `AdvanceRight` as well in the original paper.
    #
    # @return [Nil]
    def advance_right
      @right = (right + 1) % @size.length

      return if right != left

      raise 'Token queue full' if !config.upsize_stack?

      @scan_stack.update_indexes(-@left)
      @size, _left, _right = ScanStack.upsize_circular_array(@size, @left)
      @tokens, @left, @right = ScanStack.upsize_circular_array(@tokens, @left)
    end

    # Advances the {#left} pointer and lets the print stack print some of the
    # tokens it contains.
    #
    # @note Called `AdvanceLeft` as well in the original paper.
    #
    # @param token       [Token]
    # @param token_width [Integer]
    #
    # @return [Nil]
    def advance_left(token, token_width)
      return if token_width.negative?

      trim_on_break =
        if token.is_a?(Token::Break)
          # Find the first previous String token.
          idx = (left - 1) % tokens.length
          while idx != right && tokens[idx] && !tokens[idx].is_a?(Token::String) \
                && !tokens[idx].is_a?(Token::Break)
            idx = (idx - 1) % tokens.length
          end
          # Sum the widths of the last whitespace tokens.
          total = 0
          while tokens[idx].is_a?(Token::Whitespace)
            total += tokens[idx].width
            idx = (idx - 1) % tokens.length
          end
          @last_whitespaces_width = 0
          total
        end
      trim_on_break ||= 0

      print_stack.print(token, token_width, trim_on_break: trim_on_break)

      case token
      when Token::Break
        @left_total += token.width
      when Token::String
        @left_total += token_width
      end

      return if left == right

      @left = (left + 1) % tokens.length
      advance_left tokens[left], size[left]
    end

    # Updates the {#size} buffer taking into account the length of the current
    # group.
    #
    # @note Called `CheckStack` as well in the original paper.
    #
    # @param depth [Integer]
    #   depth of the group.
    #
    # @return [Nil]
    def check_stack(depth)
      return if scan_stack.empty?

      x = scan_stack.top
      case tokens[x]
      in Token::Begin
        if depth.positive?
          size[scan_stack.pop] = size[x] + right_total
          check_stack depth - 1
        end
      in Token::End
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
