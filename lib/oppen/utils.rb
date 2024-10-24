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

    # Convert a list of tokens to its wadler representation.
    # @param tokens [Array[Token]]
    # @param base_indent [Integer]
    #
    # @return [String]
    def self.tokens_to_wadler(tokens, base_indent = 4)
      out = StringIO.new
      def self.write(out, txt, nb_spaces) # rubocop:disable Lint/NestedMethodDefinition
        out.write("#{' ' * nb_spaces}#{txt}\n")
      end
      nb_spaces = base_indent
      tokens.each do |token|
        case token
        in Token::String
          write(out, "out.text '#{token}'", nb_spaces)
        in Token::LineBreak
          write(out, 'out.break', nb_spaces)
        in Token::Break
          write(out, 'out.breakable', nb_spaces)
        in Token::Begin
          write(out, 'out.group {', nb_spaces)
          nb_spaces += 2
        in Token::End
          nb_spaces -= 2
          write(out, '}', nb_spaces)
        in Token::EOF
          write(out, '', nb_spaces) # new line
        end
      end
      out.string
    end
  end
end
