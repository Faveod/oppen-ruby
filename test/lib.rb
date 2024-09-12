# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'bundler/setup'
# require 'debug'
require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/reporters'
require 'oppen'

Minitest::Reporters.use!
