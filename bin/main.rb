#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'oppen'
require_relative '../lib/oppen'
require_relative '../lib/oppen/token'

list = []

list.append(Oppen::Token::Begin.new)
list.append(Oppen::Token::String.new('XXXXXXXXXX'))
list.append(Oppen::Token::Break.new)
list.append(Oppen::Token::String.new('+'))
list.append(Oppen::Token::Break.new)
list.append(Oppen::Token::String.new('YYYYYYYYYY'))
list.append(Oppen::Token::Break.new)
list.append(Oppen::Token::String.new('+'))
list.append(Oppen::Token::Break.new)
list.append(Oppen::Token::String.new('ZZZZZZZZZZ'))
list.append(Oppen::Token::End.new)
list.append(Oppen::Token::EOF.new)

puts Oppen.pretty_print_tokens list, 25
