# frozen_string_literal: true

require_relative 'mixins'

# Oppen.
module Oppen
  # A fixed-size stack that can be popped from top and bottom.
  class ScanStack
    extend Mixins

    def initialize(size, config)
      @bottom = 0             # Points to the bottom of the stack.
      @config = config        # Printing config.
      @empty = true           # Emptiness flag.
      @stack = Array.new size # The fixed sized stack.
      @top = 0                # Points to the top of the stack.
    end

    # Whether the stack is empty.
    #
    # @return [Boolean]
    def empty? = @empty

    # The current length of the stack.
    #
    # @return [Integer]
    def length = @stack.length

    # The top element of the stack.
    #
    # @raise [RuntimeError]
    #   when accessing empty stack.
    #
    # @return [Object]
    def top
      if empty?
        raise 'Accessing empty stack from top'
      end

      @stack[@top]
    end

    # The bottom element of the stack.
    #
    # @raise [RuntimeError]
    #   when accessing empty stack.
    #
    # @return [Object]
    def bottom
      if empty?
        raise 'Accessing empty stack from bottom'
      end

      @stack[@bottom]
    end

    # Increment index (no overflow).
    #
    # @param index [Integer]
    #
    # @return [Integer]
    def increment(index)
      (index + 1) % length
    end

    # Decrement index (no overflow).
    #
    # @param index [Integer]
    #
    # @return [Integer]
    def decrement(index)
      (index - 1) % length
    end

    # Push a value to the top.
    #
    # @param value [Object]
    #
    # @raise [RuntimeError]
    #   when the stack is full and the `upsize_stack` flag is not activated in
    #   {Config}.
    #
    # @return [Nil]
    def push(value)
      if empty?
        @empty = false
      else
        @top = increment @top
        if @top == @bottom
          raise 'Stack full' if !@config.upsize_stack?

          @stack, @bottom, @top = ScanStack.upsize_circular_array @stack, @bottom
        end
      end
      @stack[@top] = value
    end

    # Pop a value from the top.
    #
    # @raise [RuntimeError]
    #   when accessing empty stack.
    #
    # @return [Nil]
    def pop
      if empty?
        raise 'Popping empty stack from top'
      end

      res = top
      if @top == @bottom
        @empty = true
      else
        @top = decrement @top
      end
      res
    end

    # Pop a value from the bottom.
    #
    # @raise [RuntimeError]
    #   when accessing empty stack.
    #
    # @return [Nil]
    def pop_bottom
      if empty?
        raise 'Popping empty stack from bottom'
      end

      res = bottom
      if @top == @bottom
        @empty = true
      else
        @bottom = increment @bottom
      end
      res
    end

    # Offset the values of the stack.
    #
    # @param offset [Integer]
    #
    # @return [Array<Integer>]
    def update_indexes(offset)
      @stack = @stack.map { |val|
        (val + offset) % length if val
      }
    end
  end
end
