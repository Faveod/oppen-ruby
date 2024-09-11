# frozen_string_literal: true

require_relative 'lib'

describe 'PrettyPrinter tests' do
  it 'must work with an empty list' do
    list = [Oppen::Token::EOF.new]
    _(Oppen.pretty_print_tokens(list)).must_equal ''

    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]
    _(Oppen.pretty_print_tokens(list)).must_equal ''
  end

  it 'must work with a simple string' do
    list = [
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::EOF.new,
    ]
    _(Oppen.pretty_print_tokens(list)).must_equal 'XXXXXXXXXX'

    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]
    _(Oppen.pretty_print_tokens(list)).must_equal 'XXXXXXXXXX'
  end

  it 'must work with string addition' do
    list = [
      Oppen::Token::Begin.new,
      *'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ'.tokens,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]

    _(Oppen.pretty_print_tokens(list, 40)).must_equal 'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ'
    _(Oppen.pretty_print_tokens(list, 25)).must_equal 'XXXXXXXXXX + YYYYYYYYYY +\n  ZZZZZZZZZZ'
    _(Oppen.pretty_print_tokens(list, 20)).must_equal 'XXXXXXXXXX +\n  YYYYYYYYYY +\n  ZZZZZZZZZZ'
  end
end
