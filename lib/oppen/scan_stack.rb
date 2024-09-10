# frozen_string_literal: true

# Oppen
module Oppen
  # Stack used by the scan in the Oppen algorithm
  class ScanStack
    def initialize(size)
      @stack = Array.new(size)
      @empty = true
      @top = @bottom = 0
    end

    def empty?
      @empty
    end

    def length
      @stack.length
    end

    def top
      if empty?
        raise 'Accessing empty stack'
      end

      @stack[@top]
    end

    def bottom
      if empty?
        raise 'Accessing empty stack'
      end

      @stack[@bottom]
    end

    def increment(index)
      (index + 1) % length
    end

    def decrement(index)
      (index - 1) % length
    end

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
