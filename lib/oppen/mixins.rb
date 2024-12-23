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
    #   # out.group(0, "", "", :consistent) {
    #   #   out.text("Hello World!", width: 12)
    #   # }
    #
    # @return [String]
    def tokens_to_wadler(tokens, base_indent: 0, printer_name: 'out', width: tokens.length * 3)
      printer = Oppen::Wadler.new(width:)
      printer.base_indent(base_indent)
      indent = 2

      handle_break_token = ->(token) {
        if token.offset.positive?
          printer.text "#{printer_name}.nest(#{token.offset}, '', '') {"
          printer.nest_open indent
          printer.break
        end

        printer.text(
          case token
          in Token::LineBreak
            "#{printer_name}.break(line_continuation: #{token.line_continuation.inspect})"
          in Token::Break
            "#{printer_name}.breakable(#{token.str.inspect}, width: #{token.width}, " \
            "line_continuation: #{token.line_continuation.inspect})"
          end,
        )

        if token.offset.positive?
          printer.nest_close indent
          printer.break
          printer.text '}'
        end
      }

      tokens.each_with_index do |token, idx|
        case token
        in Token::String
          printer.text "#{printer_name}.text(#{token.value.inspect}, width: #{token.width})"
        in Token::Break
          handle_break_token.(token)
        in Token::Begin
          printer.text "#{printer_name}.group(#{token.offset}, '', '', #{token.break_type.inspect}) {"
          printer.nest_open indent
        in Token::End
          printer.nest_close indent
          printer.break
          printer.text '}'
        in Token::EOF
          nil
        end
        printer.break if !tokens[idx + 1].is_a?(Token::End)
      end
      printer.output
    end
  end
end
