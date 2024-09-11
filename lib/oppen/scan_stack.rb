# frozen_string_literal: true

# Oppen module.
module Oppen
  # Class that represents a stack that can be popped from top and bottom.
  # The stack has a fixed size and is an Array used as a cycle.
  class ScanStack
    def initialize(size)
      @stack = Array.new(size)
      @empty = true
      @top = @bottom = 0
    end

    # @return [Boolean]
    def empty?
      @empty
    end

    # @return [Integer]
    def length
      @stack.length
    end

    # @return [Object]
    def top
      if empty?
        raise 'Accessing empty stack'
      end

      @stack[@top]
    end

    # @return [Object]
    def bottom
      if empty?
        raise 'Accessing empty stack'
      end

      @stack[@bottom]
    end

    # Helper method that increments index without causing an overflow
    #
    # @param index [Integer]
    #
    # @return [Integer]
    def increment(index)
      (index + 1) % length
    end

    # Helper method that decrements index without causing an overflow
    #
    # @param index [Integer]
    #
    # @return [Integer]
    def decrement(index)
      (index - 1) % length
    end

    # Pushes a value to the top of the stack
    #
    # @param value [Object]
    #
    # @return [Nil]
    def push(value)
      if empty?
        @empty = false
      else
        @top = increment(@top)
        if @top == @bottom
          raise 'Stack full'
        end
      end
      @stack[@top] = value
    end

    # Pops a value from the top of the stack
    #
    # @return [Nil]
    def pop
      if empty?
        raise 'Popping empty stack'
      end

      res = @stack[@top]
      if @top == @bottom
        @empty = true
      else
        @top = decrement(@top)
      end
      res
    end

    # Pops a value from the bottom of the stack
    #
    # @return [Nil]
    def pop_bottom
      if empty?
        raise 'Popping empty stack'
      end

      res = @stack[@bottom]
      if @top == @bottom
        @empty = true
      else
        @bottom = increment(@bottom)
      end
      res
    end
  end
end
