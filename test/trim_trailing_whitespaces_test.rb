# frozen_string_literal: true

require_relative 'lib'

def trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
  printer = Oppen::Wadler.new(width: 5, whitespace:)
  builder_block.call printer
  _(printer.output).must_equal expected

  printer_no_trailing = Oppen::Wadler.new(width: 5, whitespace:)
  builder_block.call printer_no_trailing, false
  _(printer_no_trailing.output).must_equal expected
end

describe 'Trim trailing whitespaces tests' do
  [
    ' ',
    '#',
    '**',
    ' *',
    '* ',
    ' * ',
    '¬',
    'éÅ',
  ].each do |whitespace|
    it "does not trim non trailing `#{whitespace}` whitespaces" do
      printer = Oppen::Wadler.new(width: 5, whitespace:)
      printer.text("#{whitespace}a#{whitespace}")
      printer.text("#{whitespace}b")
      _(printer.output).must_equal "#{whitespace}a#{whitespace}#{whitespace}b"
    end

    it "trims a pure `#{whitespace}` whitespace token" do
      printer = Oppen::Wadler.new(width: 5, whitespace:)
      printer.text(whitespace)
      printer.break
      _(printer.output).must_equal "\n"
    end

    it "trims multiple pure `#{whitespace}` whitespace tokens" do
      printer = Oppen::Wadler.new(width: 5, whitespace:)
      printer.text(whitespace * 42)
      printer.break
      _(printer.output).must_equal "\n"
    end

    it "trims a single `#{whitespace}` trailing whitespace" do
      builder_block = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace if add_trailing}")
        out.break
        out.text("#{whitespace}b")
      }
      expected = <<~LANG.chomp
        #{whitespace}a
        #{whitespace}b
      LANG

      trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
    end

    it "trims multiple `#{whitespace}` trailing whitespaces" do
      builder_block = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
        out.break
        out.text("#{whitespace}b")
      }
      expected = <<~LANG.chomp
        #{whitespace}a
        #{whitespace}b
      LANG

      trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
    end

    it "trims `#{whitespace}` whitespace of previous parent group" do
      builder_block = proc { |out, add_trailing = true|
        out.text("a#{whitespace if add_trailing}")
        out.group {
          out.group {
            out.break
            out.text('b')
          }
        }
      }
      expected = <<~LANG.chomp
        a
        b
      LANG

      trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
    end

    it "trims `#{whitespace}` whitespace of previous child group" do
      builder_block = proc { |out, add_trailing = true|
        out.group {
          out.group {
            out.group {
              out.text("a#{whitespace if add_trailing}")
            }
          }
          out.break
          out.text('b')
        }
      }
      expected = <<~LANG.chomp
        a
        b
      LANG

      trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
    end

    it "trims `#{whitespace}` of pattern: text, whitespace(s), break" do
      builder_block1 = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace if add_trailing}")
        out.break
      }
      builder_block2 = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
        out.break
      }
      expected = <<~LANG
        #{whitespace}a
      LANG

      trim_trailing_whitespaces_round_trip(builder_block1, expected, whitespace)
      trim_trailing_whitespaces_round_trip(builder_block2, expected, whitespace)
    end

    it "trims `#{whitespace}` of pattern: text, whitespace(s), breaks" do
      builder_block1 = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace if add_trailing}")
        out.break
        out.break
        out.break
        out.break
        out.break
      }
      builder_block2 = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
        out.break
        out.break
        out.break
        out.break
        out.break
      }
      expected = "#{whitespace}a\n\n\n\n\n"

      trim_trailing_whitespaces_round_trip(builder_block1, expected, whitespace)
      trim_trailing_whitespaces_round_trip(builder_block2, expected, whitespace)
    end

    it "does not trim `#{whitespace}` of pattern: text, whitespace, breaks, whitespaces" do
      builder_block = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
        out.break
        out.break
        out.text("#{whitespace}a#{whitespace * 42}")
      }
      expected = <<~LANG.chomp
        #{whitespace}a

        #{whitespace}a#{whitespace * 42}
      LANG

      trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
    end

    it "trims `#{whitespace}` of pattern: text, whitespace, breaks, whitespaces, breaks" do
      builder_block = proc { |out, add_trailing = true|
        out.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
        out.break
        out.break
        out.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
        out.break
        out.break
      }
      expected = "#{whitespace}a\n\n#{whitespace}a\n\n"

      trim_trailing_whitespaces_round_trip(builder_block, expected, whitespace)
    end
  end
end
