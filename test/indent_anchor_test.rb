# frozen_string_literal: true

require 'prettyprint'

require_relative 'lib'

def check_difference_oppen_wadler(width, expected_oppen, expected_wadler, builder_block)
  printer = Oppen::Wadler.new(width:, config: Oppen::Config.oppen)
  builder_block.call(printer)
  _(printer.output).must_equal expected_oppen, 'Oppen failed the test'

  printer = Oppen::Wadler.new(width:, config: Oppen::Config.wadler)
  builder_block.call(printer)
  _(printer.output).must_equal expected_wadler, 'Wadler failed the test'

  printer = PrettyPrint.new(''.dup, width)
  builder_block.call(printer)
  printer.flush
  _(printer.output).must_equal expected_wadler, 'PrettyPrint failed the test'
end

describe 'Indent anchor tests' do
  [
    [
      'must work with a simple group of indentation 0',
      proc { |out|
        out.group(0) {
          out.text 'Hello, World!'
          out.break
          out.text 'How are you?'
          out.break
          out.text 'I am fine and you?'
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
        How are you?
        I am fine and you?
      OPPEN
        Hello, World!
        How are you?
        I am fine and you?
      WADLER
    ],
    [
      'must work with a simple group of indentation 1',
      proc { |out|
        out.group(1) {
          out.text 'Hello, World!'
          out.break
          out.text 'How are you?'
          out.break
          out.text 'I am fine and you?'
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
         How are you?
         I am fine and you?
      OPPEN
        Hello, World!
         How are you?
         I am fine and you?
      WADLER
    ],
    [
      'must work with a simple group of indentation 2',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.break
          out.text 'How are you?'
          out.break
          out.text 'I am fine and you?'
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
          How are you?
          I am fine and you?
      OPPEN
        Hello, World!
          How are you?
          I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case of indentation 2-0',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(0) {
            out.break
            out.text 'How are you?'
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                     How are you?
                     I am fine and you?
      OPPEN
        Hello, World!
          How are you?
          I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case of indentation 2-1',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(1) {
            out.break
            out.text 'How are you?'
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                      How are you?
                      I am fine and you?
      OPPEN
        Hello, World!
           How are you?
           I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case of indentation 2-2',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(2) {
            out.break
            out.text 'How are you?'
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                       How are you?
                       I am fine and you?
      OPPEN
        Hello, World!
            How are you?
            I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case of indentation 0-0',
      proc { |out|
        out.group(0) {
          out.text 'Hello, World!'
          out.group(0) {
            out.break
            out.text 'How are you?'
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                     How are you?
                     I am fine and you?
      OPPEN
        Hello, World!
        How are you?
        I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case of indentation 0-1',
      proc { |out|
        out.group(0) {
          out.text 'Hello, World!'
          out.group(1) {
            out.break
            out.text 'How are you?'
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                      How are you?
                      I am fine and you?
      OPPEN
        Hello, World!
         How are you?
         I am fine and you?
      WADLER
    ],
    [
      'must work with a multiple groups of same indentation nested in a group',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(1) {
            out.break
            out.text 'How are you?'
          }
          out.group(1) {
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                      How are you?
                                   I am fine and you?
      OPPEN
        Hello, World!
           How are you?
           I am fine and you?
      WADLER
    ],
    [
      'must work with a multiple groups of different increasing indentation nested in a group',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(1) {
            out.break
            out.text 'How are you?'
          }
          out.group(2) {
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                      How are you?
                                    I am fine and you?
      OPPEN
        Hello, World!
           How are you?
            I am fine and you?
      WADLER
    ],
    [
      'must work with a multiple groups of different decreasing indentation nested in a group',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(2) {
            out.break
            out.text 'How are you?'
          }
          out.group(1) {
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                       How are you?
                                    I am fine and you?
      OPPEN
        Hello, World!
            How are you?
           I am fine and you?
      WADLER
    ],
    [
      'must work with 3 nested blocks of same indentation',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(2) {
            out.break
            out.text 'How'
            out.group(2) {
              out.break
              out.text 'are'
              out.break
              out.text 'you?'
            }
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                       How
                            are
                            you?
      OPPEN
        Hello, World!
            How
              are
              you?
      WADLER
    ],
    [
      'must work with 3 nested blocks of different indentation',
      proc { |out|
        out.group(2) {
          out.text 'Hello, World!'
          out.group(3) {
            out.break
            out.text 'How'
            out.group(4) {
              out.break
              out.text 'are'
              out.break
              out.text 'you?'
            }
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                        How
                               are
                               you?
      OPPEN
        Hello, World!
             How
                 are
                 you?
      WADLER
    ],
    [
      'must work with a simple nested case break outside nested',
      proc { |out|
        out.group(0) {
          out.text 'Hello, World!'
          out.break
          out.group(1) {
            out.text 'How are you?'
            out.break
            out.text 'I am fine and you?'
          }
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
        How are you?
         I am fine and you?
      OPPEN
        Hello, World!
        How are you?
         I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case text outside nested',
      proc { |out|
        out.group(0) {
          out.text 'Hello, World!'
          out.group(1) {
            out.break
            out.text 'How are you?'
            out.break
          }
          out.text 'I am fine and you?'
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
                      How are you?
                      I am fine and you?
      OPPEN
        Hello, World!
         How are you?
         I am fine and you?
      WADLER
    ],
    [
      'must work with a simple nested case text and break outside nested',
      proc { |out|
        out.group(0) {
          out.text 'Hello, World!'
          out.break
          out.group(1) {
            out.text 'How are you?'
            out.break
          }
          out.text 'I am fine and you?'
        }
      }, <<~OPPEN.chomp, <<~WADLER.chomp, [30]
        Hello, World!
        How are you?
         I am fine and you?
      OPPEN
        Hello, World!
        How are you?
         I am fine and you?
      WADLER
    ],
  ].each do |test_title, builder_block, expected_oppen, expected_wadler, values|
    values.each do |width|
      it test_title do
        check_difference_oppen_wadler width, expected_oppen, expected_wadler, builder_block
      end
    end
  end
end

describe 'Indent anchor error tests' do
  it 'must raise a LocalJumpError if no block is given to group' do
    width = 30
    printer = PrettyPrint.new ''.dup, width

    _ { printer.group(2) }.must_raise LocalJumpError

    printer = Oppen::Wadler.new(width:)

    _ { printer.group(2) }.must_raise LocalJumpError
  end
end
