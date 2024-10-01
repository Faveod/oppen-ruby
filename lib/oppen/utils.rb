# frozen_string_literal: true

# Oppen.
module Oppen
  # Utils.
  module Utils
    # Rotates circular array and triples its size.
    # @param arr [Array]
    # @param offset [Integer] Rotation amount
    #
    # @return [Array(Array, Integer, Integer)] upsized array, lhs, rhs
    def self.upsize_circular_array(arr, offset)
      size = arr.size
      arr = arr.rotate(offset)
      arr.fill(nil, size, 2 * size)
      [arr, 0, size]
    end
  end
end
