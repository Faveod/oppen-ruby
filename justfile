GEM_NAME := 'oppen'
LIB := 'lib'
LIB_FILE := LIB / GEM_NAME + '.rb'
VERSION_FILE := LIB / GEM_NAME / 'version.rb'
VERSION := shell("ruby -r ./" + VERSION_FILE  + " -e 'puts Oppen::VERSION'")

GEM_FILE := GEM_NAME + '-' + VERSION + '.gem'
PKG_OUT := 'pkg'

default: test

[group('lint')]
check: doc-stats lint

[group('develop')]
debug *args:
  bundle exec rdbg -x .rdbg.breakpoints -c -- bundle exec ruby -r ./{{LIB_FILE}} ./bin/main.rb {{args}}

[group('doc')]
doc:
  bundle exec rake doc

[group('doc')]
[group('lint')]
doc-stats:
  bundle exec yard stats --list-undoc

[group('publish')]
gem:
  mkdir -p {{PKG_OUT}}
  bundle exec gem build --strict --output {{PKG_OUT}}/{{GEM_FILE}}

[group('lint')]
lint:
  bundle exec rubocop --config .rubocop.yml

[group('publish')]
publish:
  gem -C {{PKG_OUT}} push {{GEM_FILE}}

[group('develop')]
repl:
  bundle exec irb -r ./{{LIB_FILE}} -r ./bin/repl.rb

[group('develop')]
run *args:
  bundle exec ruby -r ./{{LIB_FILE}} ./bin/main.rb {{args}}

[group('develop')]
setup:
  bundle config set --local path .vendor
  bundle install

[group('develop')]
[group('test')]
test *args:
  bundle exec rake test {{ if args == '' { '' } else { '-- ' + args } }}

[group('lint')]
typos:
  typos --sort

[group('lint')]
typos-fix:
  typos --write-changes

