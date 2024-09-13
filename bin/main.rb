#!/usr/bin/env ruby
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'oppen'

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

puts Oppen.print tokens: list, margin: 25

puts '--------------------------------------'

wadler = Oppen::Wadler.new(margin: 25)

wadler.nest {
  wadler.text 'XXXXXXXXXX'
  wadler.breakable
  wadler.text '+'
  wadler.breakable
  wadler.text 'YYYYYYYYYY'
  wadler.breakable
  wadler.text '+'
  wadler.breakable
  wadler.text 'ZZZZZZZZZZ'
}

puts wadler.output
