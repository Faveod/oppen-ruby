# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'bundler/setup'
# require 'debug'
require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/reporters'
require 'oppen'
require 'prettyprint'

Minitest::Reporters.use!

# Tests inspired by the python implementation of the Oppen algorithm.
# https://github.com/stevej2608/oppen-pretty-printer/tree/master/tests

class String
  def tokens
    words = split.map { |word| Oppen::Token::String.new(word) }
    result = [Oppen::Token::Break.new] * ((words.length * 2) - 1)
    index = 0
    words.each do |word|
      result[index] = word
      index += 2
    end
    [
      Oppen::Token::Begin.new,
      *result,
      Oppen::Token::End.new,
    ]
  end
end

class PrettyPrint
  def break
    breakable
    current_group.break
  end
end
