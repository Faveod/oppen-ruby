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

    # Config containing customization flags
    attr_reader :config

    # Callable that generate spaces
    attr_reader :genspace

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

    def initialize(margin, new_line, config, space, out)
      @buffer = out
      @config = config
      @genspace =
        if space.respond_to?(:call)
          raise ArgumentError, 'space argument must be a Proc of arity 1' \
            if space.to_proc.arity != 1

          space
        else
          ->(n) { space * n }
        end
      @items = []
      @new_line = new_line
      @margin = margin
      @space = margin
    end

    # Returns the output of the print stack
    #
    # @return [String]
    def output
      buffer.string
    end

    # Core method responsible for building the print stack and the output string.
    #
    # @note Called Print in the original paper.
    #
    # @param token [Token]
    # @param token_width [Integer]
    #
    # @return [Nil]
    def print(token, token_width)
      case token
      in Token::Begin
        handle_begin token, token_width
      in Token::End
        handle_end
      in Token::Break
        handle_break token, token_width
      in Token::String
        handle_string token, token_width
      end
    end

    # Handle Begin Token.
    #
    # @param token [Token]
    # @param token_width [Integer]
    #
    # @return [Nil]
    #
    # @see Token::Begin
    def handle_begin(token, token_width)
      if token_width > space
        type =
          if token.break_type == Token::BreakType::CONSISTENT
            Token::BreakType::CONSISTENT
          else
            Token::BreakType::INCONSISTENT
          end
        if config&.indent_anchor == Config::IndentAnchor::ON_BEGIN
          indent = token.offset
          if !items.empty?
            indent += top.offset
          end
        else
          indent = space - token.offset
        end
        push PrintStackEntry.new indent, type
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
    # @param token_width [Integer]
    #
    # @return [Nil]
    #
    # @see Token::Break
    def handle_break(token, token_width)
      block = top
      case block.break_type
      in Token::BreakType::FITS
        @space -= token.width
        write token
      in Token::BreakType::CONSISTENT
        @space = block.offset - token.offset
        indent =
          if config&.indent_anchor == Config::IndentAnchor::ON_BEGIN
            token.offset
          else
            margin - space
          end
        write token.line_continuation
        print_new_line indent
      in Token::BreakType::INCONSISTENT
        if token_width > space
          @space = block.offset - token.offset
          indent =
            if config&.indent_anchor == Config::IndentAnchor::ON_BEGIN
              token.offset
            else
              margin - space
            end
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
    # @param token [Token]
    # @param token_width [Integer]
    #
    # @return [Nil]
    #
    # @see Token::String
    def handle_string(token, token_width)
      @space = [0, space - token_width].max
      write token
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
      if config&.indent_anchor == Config::IndentAnchor::ON_BEGIN
        @space = margin - top.offset - amount
        indent margin - space
      else
        indent amount
      end
    end

    # Write a string to the output.
    #
    # @param obj [Object]
    #
    # @return [Nil]
    def write(obj)
      buffer.write(obj.to_s)
    end

    # Add indentation by `amount`.
    #
    # @note Called Indent as well in the original paper.
    #
    # @param amount [Integer]
    #
    # @return [Nil]
    def indent(amount)
      write genspace.call(amount)
    end
  end
end
