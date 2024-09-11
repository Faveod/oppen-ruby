# frozen_string_literal: true

require 'bundler/setup'
# require 'debug'
require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/reporters'

require_relative '../lib/oppen'
require_relative '../lib/oppen/token'

Minitest::Reporters.use!

class PrettyPrinterTests < Minitest::Test
  def test_empty
    list = [
      Oppen::Token::EOF.new,
    ]
    assert_equal(
      Oppen.pretty_print_tokens(list),
      '',
    )

    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]
    assert_equal(
      Oppen.pretty_print_tokens(list),
      '',
    )
  end

  def test_simple_string
    list = [
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::EOF.new,
    ]
    assert_equal(
      Oppen.pretty_print_tokens(list),
      'XXXXXXXXXX',
    )

    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]
    assert_equal(
      Oppen.pretty_print_tokens(list),
      'XXXXXXXXXX',
    )
  end

  def test_simple_string_addition
    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::Break.new,
      Oppen::Token::String.new('+'),
      Oppen::Token::Break.new,
      Oppen::Token::String.new('YYYYYYYYYY'),
      Oppen::Token::Break.new,
      Oppen::Token::String.new('+'),
      Oppen::Token::Break.new,
      Oppen::Token::String.new('ZZZZZZZZZZ'),
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]

    assert_equal(
      Oppen.pretty_print_tokens(list, 40),
      'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ',
    )
    assert_equal(
      Oppen.pretty_print_tokens(list, 25),
      'XXXXXXXXXX + YYYYYYYYYY +\n  ZZZZZZZZZZ',
    )
    assert_equal(
      Oppen.pretty_print_tokens(list, 20),
      'XXXXXXXXXX +\n  YYYYYYYYYY +\n  ZZZZZZZZZZ',
    )
  end
end
