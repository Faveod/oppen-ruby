# frozen_string_literal: true

require_relative 'lib'

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
    [
      {
        title: "does not trim non trailing `#{whitespace}` whitespaces",
        block: proc { |printer|
          printer.text("#{whitespace}a#{whitespace}")
          printer.text("#{whitespace}b")
        },
        expected: "#{whitespace}a#{whitespace}#{whitespace}b",
      },
      {
        title: "trims a pure `#{whitespace}` whitespace token",
        block: proc { |printer|
          printer.text(whitespace)
          printer.break
        },
        expected: "\n",
      },
      {
        title: "trims multiple pure `#{whitespace}` whitespace tokens",
        block: proc { |printer|
          printer.text(whitespace * 42)
          printer.break
        },
        expected: "\n",
      },
      {
        title: "trims `#{whitespace}` alternating with breaks",
        block: proc { |printer|
          printer.text(whitespace)
          printer.break
          printer.text(whitespace)
          printer.text(whitespace)
          printer.break
          printer.text(whitespace)
          printer.break
          printer.break
          printer.break
          printer.text(whitespace)
          printer.text(whitespace)
          printer.break
          printer.break
        },
        expected: "\n\n\n\n\n\n\n",
      },
    ].each do |test|
      it test[:title] do
        printer = Oppen::Wadler.new(width: 5, whitespace:)
        test[:block].(printer)
        _(printer.output).must_equal test[:expected]
      end
    end

    # Round trip tests.
    [
      {
        title: "trims a single `#{whitespace}` trailing whitespace",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace if add_trailing}")
          printer.break
          printer.text("#{whitespace}b")
        },
        expected: <<~LANG.chomp,
          #{whitespace}a
          #{whitespace}b
        LANG
      },
      {
        title: "trims multiple `#{whitespace}` trailing whitespaces",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
          printer.break
          printer.text("#{whitespace}b")
        },
        expected: <<~LANG.chomp,
          #{whitespace}a
          #{whitespace}b
        LANG
      },
      {
        title: "trims `#{whitespace}` whitespace of previous parent group",
        block: proc { |printer, add_trailing = true|
          printer.text("a#{whitespace if add_trailing}")
          printer.group {
            printer.group {
              printer.break
              printer.text('b')
            }
          }
        },
        expected: <<~LANG.chomp,
          a
          b
        LANG
      },
      {
        title: "trims `#{whitespace}` whitespace of previous child group",
        block: proc { |printer, add_trailing = true|
          printer.group {
            printer.group {
              printer.group {
                printer.text("a#{whitespace if add_trailing}")
              }
            }
            printer.break
            printer.text('b')
          }
        },
        expected: <<~LANG.chomp,
          a
          b
        LANG
      },
      {
        title: "trims `#{whitespace}` of pattern: text, whitespace, break",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace if add_trailing}")
          printer.break
        },
        expected: "#{whitespace}a\n",
      },
      {
        title: "trims `#{whitespace}` of pattern: text, whitespaces, break",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
          printer.break
        },
        expected: "#{whitespace}a\n",
      },
      {
        title: "trims `#{whitespace}` of pattern: text, whitespace, breaks",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace if add_trailing}")
          printer.break
          printer.break
          printer.break
          printer.break
        },
        expected: "#{whitespace}a\n\n\n\n",
      },
      {
        title: "trims `#{whitespace}` of pattern: text, whitespaces, breaks",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
          printer.break
          printer.break
          printer.break
          printer.break
        },
        expected: "#{whitespace}a\n\n\n\n",
      },
      {
        title: "does not trim `#{whitespace}` of pattern: text, whitespace, breaks, whitespaces",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
          printer.break
          printer.break
          printer.text("#{whitespace}a#{whitespace * 42}")
        },
        expected: <<~LANG.chomp,
          #{whitespace}a

          #{whitespace}a#{whitespace * 42}
        LANG
      },
      {
        title: "trims `#{whitespace}` of pattern: text, whitespace, breaks, whitespaces, breaks",
        block: proc { |printer, add_trailing = true|
          printer.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
          printer.break
          printer.break
          printer.text("#{whitespace}a#{whitespace * 42 if add_trailing}")
          printer.break
          printer.break
        },
        expected: "#{whitespace}a\n\n#{whitespace}a\n\n",
      },
      {
        title: "trims `#{whitespace}` from line_continuation",
        block: proc { |printer|
          printer.text('Hello World!')
          printer.break(line_continuation: "#{whitespace}^_^#{whitespace}")
          printer.text('How are you doing?')
          printer.breakable(line_continuation: "#{whitespace}^_^#{whitespace}")
        },
        expected: <<~LANG.chomp,
          Hello World!#{whitespace}^_^
          How are you doing?#{whitespace}^_^

        LANG
      },
    ].each do |test|
      it test[:title] do
        printer = Oppen::Wadler.new(width: 5, whitespace:)
        test[:block].(printer)
        _(printer.output).must_equal test[:expected]

        printer_no_trailing = Oppen::Wadler.new(width: 5, whitespace:)
        test[:block].(printer_no_trailing, false)
        _(printer_no_trailing.output).must_equal test[:expected]
      end
    end
  end
end
