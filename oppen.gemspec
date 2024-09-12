# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'oppen/version'

Gem::Specification.new do |spec|
  spec.name          = 'oppen'
  spec.version       = Oppen::VERSION
  spec.authors       = [
    'Amine Mike El Maalouf <amine.el-maalouf@epita.fr>',
    'Firas al-Khalil <firasalkhalil@gmail.com>',
  ]

  spec.summary       = 'Pretty-printing library'
  spec.description   = "Implementation of the Oppen's pretty printing algorithm"
  spec.homepage      = 'http://github.com/Faveod/oppen-ruby'
  spec.license       = 'MIT'

  # spec.metadata = {
  #   'allowed_push_host' => 'https://rubygems.org',
  #   'homepage_uri' => spec.homepage,
  #   'source_code_uri' => spec.homepage,
  #   'changelog_uri' => spec.homepage,
  #   'documentation_uri' => 'https://Amine_Mike.github.io/oppen',
  # }

  spec.files         = Dir['lib/**/*', 'bin/*', 'LICENSE', 'README.md']
  spec.bindir        = 'bin'
  spec.executables   = ['main.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~>3.3'

  spec.add_dependency 'colored', '~> 1.2'
  spec.add_dependency 'logger', '~> 1.6'
end
