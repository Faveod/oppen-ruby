# frozen_string_literal: true

require_relative 'mixins'

# Oppen.
module Oppen
  # A fixed-size stack that can be popped from top and bottom.
  class ScanStack
    extend Mixins

    def initialize(size, config)
      @bottom = 0
      @config = config
      @empty = true
      @stack = Array.new(size)
      @top = 0
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
        raise 'Accessing empty stack from top'
      end

      @stack[@top]
    end

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
    # @return [Nil]
    def push(value)
      if empty?
        @empty = false
      else
        @top = increment(@top)
        if @top == @bottom
          raise 'Stack full' if !@config.upsize_stack?

          @stack, @bottom, @top = ScanStack.upsize_circular_array(@stack, @bottom)
        end
      end
      @stack[@top] = value
    end

    # Pop a value from the top.
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
        @top = decrement(@top)
      end
      res
    end

    # Pop a value from the bottom.
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
        @bottom = increment(@bottom)
      end
      res
    end

    # Offset the values of the stack.
    #
    # @param offset [Integer]
    #
    # @return [Array[Integer]]
    def update_indexes(offset)
      @stack = @stack.map { |val|
        (val + offset) % length if val
      }
    end
  end
end
