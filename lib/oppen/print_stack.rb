# frozen_string_literal: true

# Oppen.
module Oppen
  # Class that represents a stack that builds an output string
  # using the values of the tokens that were pushed into it.
  class PrintStack
    # Class that represents an item in the print stack.
    class PrintStackEntry
      # @return [Token::BreakType] Called `break` in the original paper.
      attr_reader :break_type
      # @return [Integer] Indentation level.
      attr_reader :offset

      def initialize(offset, break_type)
        @offset = offset
        @break_type = break_type
      end
    end

    # IO element that builds the output.
    attr_reader :buffer
    # To customize the printer's behavior.
    attr_reader :config
    # Callable that generates spaces.
    attr_reader :genspace
    # Array representing the stack of PrintStackEntries.
    attr_reader :items
    # Delimiter between lines in output.
    attr_reader :new_line
    # Current available space (`index` in the original paper).
    attr_reader :space
    # Maximum allowed width for printing (`length` in the original paper).
    attr_reader :width

    def initialize(width, new_line, config, space, out)
      @buffer = out
      @config = config
      @genspace =
        if space.respond_to? :call
          raise ArgumentError, 'space argument must be a Proc of arity 1' \
            if space.to_proc.arity != 1

          space
        else
          ->(n) { space * n }
        end
      @indent = 0 # the amount of indentation to display on the next non empty new line.
      @items = []
      @new_line = new_line
      @width = width
      @space = width
    end

    # The final pretty-printed output.
    #
    # @return [String] The output of the print stack.
    def output
      buffer.truncate buffer.pos
      buffer.string
    end

    # Core method responsible for building the print stack and the output string.
    #
    # @note Called `Print` in the original paper.
    #
    # @param token         [Token]
    # @param token_width   [Integer]
    # @param trim_on_break [Integer] number of trailing whitespace characters to trim.
    #                                If zero, no character will be trimmed.
    #
    # @return [Nil]
    def print(token, token_width, trim_on_break: 0)
      case token
      in Token::Begin
        handle_begin token, token_width
      in Token::End
        handle_end
      in Token::Break
        handle_break token, token_width, trim_on_break:
      in Token::String
        handle_string token, token_width
      end
    end

    # Handle Begin Token.
    #
    # @param token       [Token]
    # @param token_width [Integer]
    #
    # @return [Nil]
    #
    # @see Token::Begin
    def handle_begin(token, token_width)
      if token_width > space
        type =
          if token.break_type == :consistent
            :consistent
          else
            :inconsistent
          end
        if config&.indent_anchor == :current_offset
          indent = token.offset
          if !items.empty?
            indent += top.offset
          end
        else
          indent = space - token.offset
        end
        push PrintStackEntry.new indent, type
      else
        push PrintStackEntry.new 0, :fits
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
    # @param token         [Token]
    # @param token_width   [Integer]
    # @param trim_on_break [Integer] number of trailing whitespace characters to trim.
    #                                If zero, no character will be trimmed.
    #
    # @return [Nil]
    #
    # @see Token::Break
    def handle_break(token, token_width, trim_on_break: 0)
      block = top
      case block.break_type
      in :fits
        # No new line is needed (the block fits on the line).
        @space -= token.width
        write token
      in :consistent
        @space = block.offset - token.offset
        indent =
          if config&.indent_anchor == :current_offset
            token.offset
          else
            width - space
          end
        erase trim_on_break
        write token.line_continuation
        print_new_line indent
      in :inconsistent
        if token_width > space
          @space = block.offset - token.offset
          indent =
            if config&.indent_anchor == :current_offset
              token.offset
            else
              width - space
            end
          erase trim_on_break
          write token.line_continuation
          print_new_line indent
        else
          @space -= token.width
          write token
        end
      end
    end

    # Handle String Token.
    #
    # @param token       [Token]
    # @param token_width [Integer]
    #
    # @return [Nil]
    #
    # @see Token::String
    def handle_string(token, token_width)
      return if token.value.empty?

      @space = [0, space - token_width].max
      if @indent.positive?
        indent @indent
        @indent = 0
      end
      write token
    end

    # Push a PrintStackEntry into the stack.
    #
    # @param print_stack_entry [PrintStackEntry]
    #
    # @return [Nil]
    def push(print_stack_entry)
      items.append print_stack_entry
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
    # @note Called `PrintNewLine` as well in the original paper.
    #
    # @param amount [Integer] indentation amount.
    #
    # @return [Nil]
    def print_new_line(amount)
      write new_line
      if config&.indent_anchor == :current_offset
        @space = width - top.offset - amount
        @indent = width - space
      else
        @indent = amount
      end
    end

    # Write a string to the output.
    #
    # @param obj [Object]
    #
    # @return [Nil]
    def write(obj)
      buffer.write obj.to_s
    end

    # Erase the last `count` characters.
    #
    # @param count [Integer]
    #
    # @return [Nil]
    def erase(count = 0)
      raise ArgumentError, "count = #{count} must be non-negative" if count.negative?

      buffer.seek(-count, IO::SEEK_CUR)
      @space += count
    end

    # Add indentation by `amount`.
    #
    # @note Called `Indent` as well in the original paper.
    #
    # @param amount [Integer]
    #
    # @return [Nil]
    def indent(amount)
      raise ArgumentError 'Indenting using negative amount' if amount.negative?

      write genspace.(amount) if amount.positive?
    end
  end
end
