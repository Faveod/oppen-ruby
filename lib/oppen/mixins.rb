# frozen_string_literal: true

module Oppen
  # Mixins.
  module Mixins
    # Rotates circular array and triples its size.
    # This method is not for public use.
    #
    # @param arr    [Array]   the circular array.
    # @param offset [Integer] rotation amount.
    #
    # @return [Array<Array, Integer, Integer>] upsized array, lhs, rhs.
    def upsize_circular_array(arr, offset)
      size = arr.size
      arr = arr.rotate offset
      arr.fill nil, size, 2 * size
      [arr, 0, size]
    end

    # Convert a list of tokens to its wadler representation.
    #
    # This method reverse engineers a tokens list to transform it into
    # Wadler printing commands.
    # It can be particularly useful when debugging a black box program.
    #
    # @param tokens       [Array<Token>] the list of tokens.
    # @param base_indent  [Integer]      the base indentation amount of the output.
    # @param printer_name [String]       the name of the Wadler instance in the output.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.group {
    #     out.text('Hello World!')
    #   }
    #   out.show_print_commands(out_name: 'out')
    #
    #   # =>
    #   # out.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
    #   #   out.text("Hello World!", width: 12)
    #   # }
    #
    # @return [String]
    def tokens_to_wadler(tokens, base_indent: 0, printer_name: 'out')
      nb_spaces = base_indent
      out = StringIO.new

      write = ->(txt) {
        out << (' ' * nb_spaces) << txt << "\n"
      }
      display_break_token = ->(token) {
        if token.offset.positive?
          write.("#{printer_name}.nest(#{token.offset}, \"\", \"\") {")
          nb_spaces += 2
        end

        case token
        in Token::LineBreak
          write.("#{printer_name}.break(line_continuation: #{token.line_continuation.inspect})")
        in Token::Break
          write.("#{printer_name}.breakable(#{token.str.inspect}, width: #{token.width}, " \
                 "line_continuation: #{token.line_continuation.inspect})")
        end

        if token.offset.positive?
          nb_spaces -= 2
          write.('}')
        end
      }

      tokens.each do |token|
        case token
        in Token::String
          write.("#{printer_name}.text(#{token.value.inspect}, width: #{token.width})")
        in Token::Break
          display_break_token.(token)
        in Token::Begin
          write.("#{printer_name}.group(#{token.offset}, \"\", \"\", #{token.break_type_name}) {")
          nb_spaces += 2
        in Token::End
          nb_spaces -= 2
          write.('}')
        in Token::EOF
          write.('') # new line.
        end
      end
      out.string
    end
  end
end
