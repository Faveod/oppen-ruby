# frozen_string_literal: true

require_relative 'lib'

describe 'surround' do
  [
    {
      title: 'prints lft and rg only',
      block: proc { |out|
        out.surround('{', '}').text('!')
      },
      expected: '{}!',
    },
    {
      title: 'accepts a block',
      block: proc { |out|
        out.surround('{', '}') {
          out.text '1'
        }
      },
      expected: '{1}',
    },
    {
      title: 'breaks on left and right inconsistently by default',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}') {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
        1}
      OUT
    },
    {
      title: 'force breaks on left',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', lft_force_break: true) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
        1}
      OUT
    },
    {
      title: 'force breaks on left with indent',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', indent: 2, lft_force_break: true) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
          1}
      OUT
    },
    {
      title: 'force breaks on right',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', rgt_force_break: true) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
        1
        }
      OUT
    },
    {
      title: 'force breaks on right with indent',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', indent: 2, rgt_force_break: true) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
          1
          }
      OUT
    },
    {
      title: 'prevents breaks on left',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', lft_can_break: false) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{1
        }
      OUT
    },
    {
      title: 'prevents breaks on left with indent',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', indent: 2, lft_can_break: false) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{1
          }
      OUT
    },
    {
      title: 'prevents breaks on right',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', rgt_can_break: false) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
        1}
      OUT
    },
    {
      title: 'prevents breaks on right with indent',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', indent: 2, rgt_can_break: false) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
          1}
      OUT
    },
    {
      title: 'can change breakable',
      block: proc { |out|
        out.surround('{', '}', lft_breakable: '<', rgt_breakable: '>') {
          out.text '1'
        }
      },
      expected: '{<1>}',
    },
    {
      title: 'can change breakable and breaks on left and right inconsistently by default',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', lft_breakable: '<', rgt_breakable: '>') {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
        1>}
      OUT
    },
    {
      title: 'can change breakable and prevent left break',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', lft_breakable: '<', lft_can_break: false, rgt_breakable: '>') {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{1
        }
      OUT
    },
    {
      title: 'can change breakable and prevent right break',
      block: proc { |out|
        out.text 'A long long string'
        out.surround('{', '}', lft_breakable: '<', rgt_breakable: '>', rgt_can_break: false) {
          out.text '1'
        }
      },
      expected: <<~OUT.chomp,
        A long long string{
        1}
      OUT
    },
  ].each do |test|
    it test[:title] do
      assert_wadler 10, test[:expected], test[:block]
    end
  end
end

describe 'helpers for surround' do
  padding_no = ->(name) {
    proc { |out|
      out.send(name) {
        out.text '1'
      }
    }
  }
  padding_yes = ->(name) {
    proc { |out|
      out.send(name, padding: '~') {
        out.text '1'
      }
    }
  }
  [
    [:angles, %w[< >]],
    [:braces, %w[{ }]],
    [:brackets, %w{[ ]}],
    [:parens, %w[( )]],
  ].each do |name, chars|
    [
      {
        title: "prints #{name} w/o padding",
        block: padding_no.(name),
        expected: "#{chars[0]}1#{chars[1]}",
      },
      {
        title: "prints #{name} w padding",
        block: padding_yes.(name),
        expected: "#{chars[0]}~1~#{chars[1]}",
      },
      {
        title: "prints #{name}_break_both w/o padding",
        block: padding_no.("#{name}_break_both"),
        expected: <<~OUT.chomp,
          #{chars[0]}
          1
          #{chars[1]}
        OUT
      },
      {
        title: "prints #{name}_break_both w padding but removes them",
        block: padding_yes.("#{name}_break_both"),
        expected: <<~OUT.chomp,
          #{chars[0]}
          1
          #{chars[1]}
        OUT
      },
      {
        title: "prints #{name}_break_non w/o padding but removes them",
        block: padding_no.("#{name}_break_none"),
        expected: "#{chars[0]}1#{chars[1]}",
      },
      {
        title: "prints #{name}_break_non w padding but removes them",
        block: padding_yes.("#{name}_break_none"),
        expected: "#{chars[0]}1#{chars[1]}",
      },
    ].each do |test|
      it test[:title] do
        assert_wadler 10, test[:expected], test[:block]
      end
    end
  end

  [
    [:backticks, '`'],
    [:quote_double, '"'],
    [:quote_single, "'"],
  ].each do |name, char|
    [
      {
        title: "prints #{name}",
        block: padding_no.(name),
        expected: "#{char}1#{char}",
      },
    ].each do |test|
      it test[:title] do
        assert_wadler 10, test[:expected], test[:block]
      end
    end
  end
end
