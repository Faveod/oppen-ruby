#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'oppen'
require_relative '../lib/oppen'
require_relative '../lib/oppen/token'

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

puts Oppen.pretty_print_tokens list, 25
