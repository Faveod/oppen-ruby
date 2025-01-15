# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) if !$LOAD_PATH.include?(lib)

require 'oppen/version'

Gem::Specification.new do |spec|
  spec.name          = 'oppen'
  spec.version       = Oppen::VERSION
  spec.authors       = [
    'Amine Mike El Maalouf <amine.el-maalouf@epita.fr>',
    'Firas al-Khalil <firas.alkhalil@faveod.com>',
  ]
  spec.summary       = 'Pretty-printing library'
  spec.description   = "Implementation of the Oppen's pretty printing algorithm"
  spec.homepage      = 'http://github.com/Faveod/oppen-ruby'
  spec.license       = 'MIT'

  spec.files                 = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths         = ['lib']
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1')
end
