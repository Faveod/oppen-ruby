# frozen_string_literal: true

require 'rake'
require 'rdoc/task'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'minitest/test_task'
require 'shellwords'
require 'yard'

require_relative 'lib/oppen/version'

Minitest::TestTask.create do |t|
  args = [//]
  args = ARGV[2..] if ARGV.length > 2

  t.extra_args << '-n' << "/#{Regexp.union(*args)}/"
  t.warning = true
  t.verbose = false
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = %w[
    --output-dir doc
    --markup markdown
    --markup-provider redcarpet
    --fail-on-warning
    --readme README.md
    - LICENSE docs/*
  ]
end
task doc: :yard

desc 'Run all tests or a specific test'
task default: :test
