# frozen_string_literal: true

require_relative 'lib'

def customization_build_output(printer)
  printer.group(indent: 2) {
    printer.text 'function'
    printer.breakable
    printer.text 'test('
    printer.group(:inconsistent, indent: 2) {
      printer.break
      printer.text 'int index,'
      printer.breakable
      printer.text 'char character,'
      printer.breakable
      printer.text 'float precision,'
      printer.breakable
      printer.text 'double trouble'
    }
    printer.breakable
    printer.text ')'
  }
end

describe 'Inconsistent break tests' do
  it 'must work in a group if the line fits' do
    printer = Oppen::Wadler.new(width: 100)
    printer.group(indent: 2) {
      printer.text 'function'
      printer.breakable
      printer.text 'test('
      printer.group(:inconsistent, indent: 2) {
        printer.breakable
        printer.text 'int index,'
        printer.breakable
        printer.text 'char character,'
        printer.breakable
        printer.text 'float precision,'
        printer.breakable
        printer.text 'double trouble'
      }
      printer.breakable
      printer.text ')'
    }
    _(printer.output).must_equal <<~LANG.chomp
      function test( int index, char character, float precision, double trouble )
    LANG
  end

  it 'must work in a group if the line doesn\'t fit' do
    printer = Oppen::Wadler.new(width: 45)
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
        test(
          int index, char character,
          float precision, double trouble
        )
    LANG
  end
end

describe 'Spaces tests' do
  it 'must work with a string of length 1' do
    printer = Oppen::Wadler.new(width: 45, space_gen: '*')
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      **test(
      ****int index, char character,
      ****float precision, double trouble
      **)
    LANG
  end

  it 'must work with a string of length greater than 1' do
    printer = Oppen::Wadler.new(width: 45, space_gen: '**')
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      ****test(
      ********int index, char character,
      ********float precision, double trouble
      ****)
    LANG
  end

  it 'must work with an UTF-8 string' do
    printer = Oppen::Wadler.new(width: 45, space_gen: 'ω')
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      ωωtest(
      ωωωωint index, char character,
      ωωωωfloat precision, double trouble
      ωω)
    LANG
  end

  it 'must work with a lambda' do
    printer = Oppen::Wadler.new(width: 45, space_gen: ->(n) { '*' * n })
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      **test(
      ****int index, char character,
      ****float precision, double trouble
      **)
    LANG
  end

  it 'must work with an UTF-8 string lambda' do
    printer = Oppen::Wadler.new(width: 45, space_gen: ->(n) { 'ω' * n })
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      ωωtest(
      ωωωωint index, char character,
      ωωωωfloat precision, double trouble
      ωω)
    LANG
  end

  it 'must work with a lambda different from default' do
    printer = Oppen::Wadler.new(width: 45, space_gen: ->(n) { '*' * n * 2 })
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      ****test(
      ********int index, char character,
      ********float precision, double trouble
      ****)
    LANG
  end

  it 'must work with a proc' do
    printer = Oppen::Wadler.new(width: 45, space_gen: proc { |n| '*' * n })
    customization_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      function
      **test(
      ****int index, char character,
      ****float precision, double trouble
      **)
    LANG
  end

  it 'must raise an error for a lambda of arity different than one' do
    printer = Oppen::Wadler.new(width: 45, space_gen: ->(n, _o) { '*' * n })
    _ { printer.output }.must_raise ArgumentError

    printer = Oppen::Wadler.new(width: 45, space_gen: -> { '*' })
    _ { printer.output }.must_raise ArgumentError

    printer = Oppen::Wadler.new(width: 45, space_gen: ->(*_args) { '*' })
    _ { printer.output }.must_raise ArgumentError
  end

  # The indentation lambda can yield a fixed size string indepedant of the indentation level.
  # In these cases, the fixed sized string should not be displayed if the indentation is 0.
  it 'calls space_gen only when indent is positive' do
    printer = Oppen::Wadler.new(width: 10, space_gen: ->(_n) { '*******' })
    printer.group {
      printer.text 'Hello'
      printer.break
      printer.text 'World'
    }
    # Bad output:
    # Hello
    # *******World
    _(printer.output).must_equal <<~LANG.chomp
      Hello
      World
    LANG
  end
end

describe 'Line delimiter tests' do
  it 'must work with an ASCII delimiter' do
    printer = Oppen::Wadler.new(width: 45, new_line: '$')
    customization_build_output(printer)
    _(printer.output)
      .must_equal 'function$  test($    int index, char character,$    float precision, double trouble$  )'
  end

  it 'must work with an UTF-8 delimiter' do
    printer = Oppen::Wadler.new(width: 45, new_line: 'Φ')
    customization_build_output(printer)
    _(printer.output)
      .must_equal 'functionΦ  test(Φ    int index, char character,Φ    float precision, double troubleΦ  )'
  end
end

describe 'Break delimiter tests' do
  it 'must work with a different delimiter' do
    printer = Oppen::Wadler.new(width: 45)
    printer.group {
      printer.breakable ''
      printer.text 'Hello'
      printer.breakable ', '
      printer.text 'World!'
    }
    _(printer.output).must_equal 'Hello, World!'
  end

  it 'must work with an UTF-8 delimiter' do
    printer = Oppen::Wadler.new(width: 45)
    printer.group {
      printer.breakable ''
      printer.text 'Hello'
      printer.breakable ' ʃ '
      printer.text 'World!'
    }
    _(printer.output).must_equal 'Hello ʃ World!'
  end
end

describe 'Nest delimiter tests' do
  def nest_delimiter_build_output(printer, delim)
    printer.group {
      printer.group(indent: 2) {
        printer.text 'function'
        printer.breakable
        printer.text 'foo()'
      }
      printer.break
      printer.nest(delim:, indent: 2) {
        printer.group {
          printer.text 'Hello'
          printer.breakable(', ')
          printer.text 'World!'
        }
      }
    }
  end

  it 'must work with an open and close object' do
    printer = Oppen::Wadler.new(width: 5)
    nest_delimiter_build_output(printer, %w[{ }])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
      {
        Hello
        World!
      }
    LANG
  end

  it 'must work with no open and close object' do
    printer = Oppen::Wadler.new(width: 5)
    nest_delimiter_build_output(printer, [])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
      Hello
        World!
    LANG
  end

  it 'must work with only an open object' do
    printer = Oppen::Wadler.new(width: 5)
    nest_delimiter_build_output(printer, ['{', ''])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
      {
        Hello
        World!
    LANG
  end

  it 'must work with only a close object' do
    printer = Oppen::Wadler.new(width: 5)
    nest_delimiter_build_output(printer, ['', '}'])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
      Hello
        World!
      }
    LANG
  end

  it 'must work with an UTF-8 string' do
    printer = Oppen::Wadler.new(width: 5)
    nest_delimiter_build_output(printer, %w[Ϯ Ϯ])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
      Ϯ
        Hello
        World!
      Ϯ
    LANG
  end
end

describe 'Group delimiter tests' do
  def group_delimiter_build_output(printer, delim)
    printer.group {
      printer.group(indent: 2) {
        printer.text 'function'
        printer.breakable
        printer.text 'foo()'
      }
      printer.group(delim:, indent: 2) {
        printer.group {
          printer.break
          printer.text 'Hello'
          printer.breakable ', '
          printer.text 'World!'
        }
      }
    }
  end

  it 'must work with an open and close object' do
    printer = Oppen::Wadler.new(width: 5)
    group_delimiter_build_output(printer, %i[{ }])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
        {
        Hello
        World!
        }
    LANG
  end

  it 'must work with no open and close object' do
    printer = Oppen::Wadler.new(width: 5)
    group_delimiter_build_output(printer, nil)
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
        Hello
        World!
    LANG
  end

  it 'must work with only an open object' do
    printer = Oppen::Wadler.new(width: 5)
    group_delimiter_build_output(printer, ['{', ''])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
        {
        Hello
        World!
    LANG
  end

  it 'must work with only a close object' do
    printer = Oppen::Wadler.new(width: 5)
    group_delimiter_build_output(printer, ['', '}'])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
        Hello
        World!
        }
    LANG
  end

  it 'must work with an UTF-8 string' do
    printer = Oppen::Wadler.new(width: 5)
    group_delimiter_build_output(printer, %w[Ϯ Ϯ])
    _(printer.output).must_equal <<~LANG.chomp
      function
        foo()
        Ϯ
        Hello
        World!
        Ϯ
    LANG
  end
end

describe 'Line continuation tests' do
  def line_continuation_build_output(printer, break_type = :consistent,
                                     line_continuation = ',')
    printer.group {
      printer.text '['
      printer.group(break_type, indent: 2) {
        printer.breakable ''
        printer.text '1'
        printer.breakable(', ', line_continuation:)
        printer.text '2'
        printer.breakable(', ', line_continuation:)
        printer.text '3'
      }
      printer.breakable('', line_continuation:)
      printer.text ']'
    }
  end
  it 'must not display line continuation if line fits' do
    printer = Oppen::Wadler.new(width: 20)
    line_continuation_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      [1, 2, 3]
    LANG
  end

  it 'must display line continuation if line does not fit (CONSISTENT break)' do
    printer = Oppen::Wadler.new(width: 3)
    line_continuation_build_output(printer)
    _(printer.output).must_equal <<~LANG.chomp
      [
        1,
        2,
        3,
      ]
    LANG
  end

  it 'must display line continuation if line does not fit (INCONSISTENT break)' do
    printer = Oppen::Wadler.new(width: 7)
    line_continuation_build_output(printer, :inconsistent)
    _(printer.output).must_equal <<~LANG.chomp
      [1, 2,
        3,
      ]
    LANG
  end

  it 'must work with UTF-8 string' do
    printer = Oppen::Wadler.new(width: 3)
    line_continuation_build_output(printer, :consistent, 'Ѿ')
    _(printer.output).must_equal <<~LANG.chomp
      [
        1Ѿ
        2Ѿ
        3Ѿ
      ]
    LANG
  end

  it 'must raise an error when line_continuation is nil' do
    printer = Oppen::Wadler.new(width: 3)
    _ { line_continuation_build_output(printer, :consistent, nil) }.must_raise ArgumentError
  end
end
