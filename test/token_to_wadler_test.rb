# frozen_string_literal: true

require_relative 'lib'

describe 'Token to wadler tests' do
  [
    {
      title: 'displays empty token list',
      block: proc { |printer|
        printer
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
        }

      LANG
    },
    {
      title: 'displays a simple text token',
      block: proc { |printer|
        printer.text('Hello World!')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("Hello World!", width: 12)
        }

      LANG
    },
    {
      title: 'displays a text token that contains quotes',
      block: proc { |printer|
        printer.text('"\'Hello World!\'"')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("\\"'Hello World!'\\"", width: 16)
        }

      LANG
    },
    {
      title: 'displays a text token that contains utf-8 characters',
      block: proc { |printer|
        printer.text('Ḽơᶉëᶆ ȋṕšᶙṁ ḍỡḽǭᵳ')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("Ḽơᶉëᶆ ȋṕšᶙṁ ḍỡḽǭᵳ", width: 17)
        }

      LANG
    },
    {
      title: 'displays a text token with arguments',
      block: proc { |printer|
        printer.text('Hello World!', width: 42)
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("Hello World!", width: 42)
        }

      LANG
    },
    {
      title: 'displays a text token with trailing whitespaces',
      block: proc { |printer|
        printer.text('Hello World!  ')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("Hello World!", width: 12)
          printer.text("  ", width: 2)
        }

      LANG
    },
    {
      title: 'displays a simple break token',
      block: proc(&:break),
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.break(line_continuation: "")
        }

      LANG
    },
    {
      title: 'displays a break token with arguments',
      block: proc { |printer|
        printer.break(line_continuation: '##')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.break(line_continuation: "##")
        }

      LANG
    },
    {
      title: 'displays a simple breakable token',
      block: proc(&:breakable),
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.breakable(" ", width: 1, line_continuation: "")
        }

      LANG
    },
    {
      title: 'displays a breakable token with arguments',
      block: proc { |printer|
        printer.breakable('**', width: 42, line_continuation: '##')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.breakable("**", width: 42, line_continuation: "##")
        }

      LANG
    },
    {
      title: 'displays a simple group token',
      block: proc { |printer|
        printer.group {
          printer.text('Hello World!')
        }
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("Hello World!", width: 12)
        }

      LANG
    },
    {
      title: 'displays a group token with arguments',
      block: proc { |printer|
        printer.group(2, '{', '}', Oppen::Token::BreakType::INCONSISTENT) {
          printer.text('Hello World!')
        }
      },
      expected: <<~LANG,
        printer.group(2, "", "", Oppen::Token::BreakType::INCONSISTENT) {
          printer.break(line_continuation: "")
          printer.text("{", width: 1)
          printer.text("Hello World!", width: 12)
          printer.break(line_continuation: "")
          printer.text("}", width: 1)
        }

      LANG
    },
    {
      title: 'displays alternating text, breaks and breakables',
      block: proc { |printer|
        printer.text('Hello World!')
        printer.break
        printer.breakable
        printer.break
        printer.text('Hello World!')
        printer.breakable
        printer.breakable
        printer.text('Hello World!')
        printer.text('Hello World!')
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("Hello World!", width: 12)
          printer.break(line_continuation: "")
          printer.breakable(" ", width: 1, line_continuation: "")
          printer.break(line_continuation: "")
          printer.text("Hello World!", width: 12)
          printer.breakable(" ", width: 1, line_continuation: "")
          printer.breakable(" ", width: 1, line_continuation: "")
          printer.text("Hello World!", width: 12)
          printer.text("Hello World!", width: 12)
        }

      LANG
    },
    {
      title: 'displays nested group tokens',
      block: proc { |printer|
        printer.group {
          printer.group {
            printer.group {
              printer.group {
                printer.group {
                  printer.text('Hello World!')
                }
              }
            }
          }
        }
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
            printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
              printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
                printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
                  printer.text("Hello World!", width: 12)
                }
              }
            }
          }
        }

      LANG
    },
    {
      title: 'displays a simple nest token',
      block: proc { |printer|
        printer.nest(2) {
          printer.breakable
          printer.text('Hello World!')
          printer.break
        }
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.nest(2, "", "") {
            printer.breakable(" ", width: 1, line_continuation: "")
          }
          printer.text("Hello World!", width: 12)
          printer.nest(2, "", "") {
            printer.break(line_continuation: "")
          }
        }

      LANG
    },
    {
      title: 'displays a nest token with arguments',
      block: proc { |printer|
        printer.nest(2, '{', '}') {
          printer.breakable
          printer.text('Hello World!')
          printer.break
        }
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.text("{", width: 1)
          printer.nest(2, "", "") {
            printer.break(line_continuation: "")
          }
          printer.nest(2, "", "") {
            printer.breakable(" ", width: 1, line_continuation: "")
          }
          printer.text("Hello World!", width: 12)
          printer.nest(2, "", "") {
            printer.break(line_continuation: "")
          }
          printer.break(line_continuation: "")
          printer.text("}", width: 1)
        }

      LANG
    },
    {
      title: 'displays nested nest tokens',
      block: proc { |printer|
        printer.nest(2) {
          printer.nest(2) {
            printer.nest(2) {
              printer.breakable
              printer.text('Hello World!')
              printer.break
            }
          }
        }
      },
      expected: <<~LANG,
        printer.group(0, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.nest(6, "", "") {
            printer.breakable(" ", width: 1, line_continuation: "")
          }
          printer.text("Hello World!", width: 12)
          printer.nest(6, "", "") {
            printer.break(line_continuation: "")
          }
        }

      LANG
    },
    {
      title: 'displays nested nest and group tokens',
      block: proc { |printer|
        printer.group(2) {
          printer.nest(2) {
            printer.group(2) {
              printer.nest(2) {
                printer.breakable
                printer.text('Hello World!')
                printer.break
              }
            }
          }
        }
      },
      expected: <<~LANG,
        printer.group(2, "", "", Oppen::Token::BreakType::CONSISTENT) {
          printer.group(2, "", "", Oppen::Token::BreakType::CONSISTENT) {
            printer.nest(4, "", "") {
              printer.breakable(" ", width: 1, line_continuation: "")
            }
            printer.text("Hello World!", width: 12)
            printer.nest(4, "", "") {
              printer.break(line_continuation: "")
            }
          }
        }

      LANG
    },
  ].each do |test|
    it test[:title] do
      printer = Oppen::Wadler.new
      test[:block].(printer)
      _(printer.show_print_commands(printer_name: 'printer')).must_equal test[:expected]
    end
  end
end
