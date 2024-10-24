# frozen_string_literal: true

module Oppen
  # Mixins.
  module Mixins
    # Rotates circular array and triples its size.
    # This method is not for public use.
    #
    # @param arr [Array]
    # @param offset [Integer] Rotation amount
    #
    # @return [Array<Array, Integer, Integer>] upsized array, lhs, rhs
    def upsize_circular_array(arr, offset)
      size = arr.size
      arr = arr.rotate(offset)
      arr.fill(nil, size, 2 * size)
      [arr, 0, size]
    end

    # Convert a list of tokens to its wadler representation.
    #
    # @param tokens [Array[Token]]
    # @param base_indent [Integer]
    #
    # @return [String]
    def tokens_to_wadler(tokens, base_indent = 4)
      out = StringIO.new
      write = ->(txt, nb_spaces) {
        out.write("#{' ' * nb_spaces}#{txt}\n")
      }
      nb_spaces = base_indent
      tokens.each do |token|
        case token
        in Token::String
          write.call("out.text '#{token}'", nb_spaces)
        in Token::LineBreak
          write.call('out.break', nb_spaces)
        in Token::Break
          write.call('out.breakable', nb_spaces)
        in Token::Begin
          write.call('out.group {', nb_spaces)
          nb_spaces += 2
        in Token::End
          nb_spaces -= 2
          write.call('}', nb_spaces)
        in Token::EOF
          write.call('', nb_spaces) # new line
        end
      end
      out.string
    end
  end
end
