# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'oppen'
  spec.version       = '1.0.0'
  spec.authors       = ['Amine Mike El Maalouf']
  spec.email         = ['amine.el-maalouf@epita.fr']

  spec.summary       = 'Oppen pretty printer'
  spec.description   = 'Implementation of the pretty printing algorithm ' \
                       'present in the appendix of Oppen\'s paper'
  spec.homepage      = 'http://github.com/Amine_Mike/oppen'
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
