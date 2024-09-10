GEM_NAME := 'oppen'
LIB := 'lib'
LIB_FILE := LIB / GEM_NAME + '.rb'
VERSION_FILE := LIB / GEM_NAME / 'version.rb'
VERSION := shell("ruby -r ./" + VERSION_FILE  + " -e 'puts Oppen::VERSION'")

GEM_FILE := GEM_NAME + '-' + VERSION + '.gem'
PKG_OUT := 'pkg'

BIN_DIR := 'bin'
MAIN_SCRIPT := BIN_DIR / 'main.rb'
REPL_SCRIPT := BIN_DIR / 'repl.rb'

EXEC := 'bundle exec'
RAKE := EXEC + ' rake'
IRB := EXEC + ' irb'
RUBY := EXEC + ' ruby'

default: test

[group('lint')]
check: doc-stats lint

[group('develop')]
debug *args:
  bundle exec rdbg -x .rdbg.breakpoints -c -- bundle exec ruby -r ./{{LIB_FILE}} {{MAIN_SCRIPT}} {{args}}

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
publish: gem
  gem -C {{PKG_OUT}} push {{GEM_FILE}}

[group('develop')]
repl:
  bundle exec irb -r ./{{LIB_FILE}} -r ./{{REPL_SCRIPT}}

[group('develop')]
run *args:
  bundle exec ruby -r ./{{LIB_FILE}} ./{{MAIN_SCRIPT}} {{args}}

[group('develop')]
setup:
  bundle config set --local path .vendor
  bundle install

[group('develop')]
[group('test')]
test *args:
  bundle exec rake test {{ if args == '' { '' } else { '-- ' + args } }}
