# frozen_string_literal: true

module Oppen
  # Mixins.
  module Mixins
    # Rotates circular array and triples its size.
    #
    # @!visibility private
    # @note This method is not for public use.
    #
    # @param arr    [Array]
    #   the circular array.
    # @param offset [Integer]
    #   rotation amount.
    #
    # @return [Array<Array, Integer, Integer>]
    #   upsized array, lhs, rhs.
    def upsize_circular_array(arr, offset)
      size = arr.size
      arr = arr.rotate offset
      arr.fill nil, size, 2 * size
      [arr, 0, size]
    end

    # @return [String]
    def tokens_to_wadler(tokens, base_indent: 0, printer_name: 'out', width: tokens.length * 3)
      printer = Oppen::Wadler.new(base_indent: base_indent, indent: 2, width: width)

      handle_break_token = ->(token) {
        if token.offset.positive?
          printer
            .text("#{printer_name}.nest(indent: #{token.offset}) {")
            .nest_open
            .break
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

        printer.nest_close.break.text '}' if token.offset.positive?
      }

      tokens.each_with_index do |token, idx|
        case token
        in Token::String
          printer.text "#{printer_name}.text(#{token.value.inspect}, width: #{token.width})"
        in Token::Break
          handle_break_token.(token)
        in Token::Begin
          printer
            .text("#{printer_name}.group(#{token.break_type.inspect}, indent: #{token.offset}) {")
            .nest_open
        in Token::End
          printer.nest_close.break.text '}'
        in Token::EOF
          nil
        end
        printer.break if !tokens[idx + 1].is_a?(Token::End)
      end

      printer.output
    end
  end
end
