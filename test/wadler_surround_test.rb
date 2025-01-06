# frozen_string_literal: true

require_relative 'lib'

describe 'surround' do
  it 'prints lft and rg only' do
    width = 10
    block = proc { |out|
      out.surround('{', '}').text('!')
    }
    assert_wadler width, '{}!', block
  end

  it 'accepts a block' do
    width = 10
    block = proc { |out|
      out.surround('{', '}') {
        out.text '1'
      }
    }
    assert_wadler width, '{1}', block
  end

  it 'breaks on left and right inconsistently by default' do
    width = 10
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}') {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
      1}
    OUT
  end

  it 'force breaks on left' do
    width = 10
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', lft_force_break: true) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
      1}
    OUT
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', indent: 2, lft_force_break: true) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
        1}
    OUT
  end

  it 'force breaks on right' do
    width = 10
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', rgt_force_break: true) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
      1
      }
    OUT
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', indent: 2, rgt_force_break: true) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
        1
        }
    OUT
  end

  it 'prevents breaks on left' do
    width = 10
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', lft_can_break: false) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{1
      }
    OUT
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', indent: 2, lft_can_break: false) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{1
        }
    OUT
  end

  it 'prevents breaks on right' do
    width = 10
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', rgt_can_break: false) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
      1}
    OUT
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', indent: 2, rgt_can_break: false) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
        1}
    OUT
  end

  it 'can change breakables' do
    width = 10
    block = proc { |out|
      out.surround('{', '}', lft_breakable: '<', rgt_breakable: '>') {
        out.text '1'
      }
    }
    assert_wadler width, '{<1>}', block
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', lft_breakable: '<', rgt_breakable: '>') {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
      1>}
    OUT
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', lft_breakable: '<', lft_can_break: false, rgt_breakable: '>') {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{1
      }
    OUT
    block = proc { |out|
      out.text 'A long long string'
      out.surround('{', '}', lft_breakable: '<', rgt_breakable: '>', rgt_can_break: false) {
        out.text '1'
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      A long long string{
      1}
    OUT
  end
end

describe 'helpers for surround' do
  width = 10
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
    it "prints #{name} w/o padding" do
      assert_wadler width, "#{chars[0]}1#{chars[1]}", padding_no.(name)
    end

    it "prints #{name} w padding" do
      assert_wadler width, "#{chars[0]}~1~#{chars[1]}", padding_yes.(name)
    end

    it "prints #{name}_break_both w/o padding" do
      assert_wadler width, <<~OUT.chomp, padding_no.("#{name}_break_both")
        #{chars[0]}
        1
        #{chars[1]}
      OUT
    end

    it "prints #{name}_break_both w padding but removes them" do
      assert_wadler width, <<~OUT.chomp, padding_yes.("#{name}_break_both")
        #{chars[0]}
        1
        #{chars[1]}
      OUT
    end

    it "prints #{name}_break_non w/o padding but removes them" do
      assert_wadler width, "#{chars[0]}1#{chars[1]}", padding_no.("#{name}_break_none")
    end

    it "prints #{name}_break_non w padding but removes them" do
      assert_wadler width, "#{chars[0]}1#{chars[1]}", padding_yes.("#{name}_break_none")
    end
  end

  [
    [:backticks, '`'],
    [:quote_double, '"'],
    [:quote_single, "'"],
  ].each do |name, char|
    it "prints #{name}" do
      assert_wadler width, "#{char}1#{char}", padding_no.(name)
    end
  end
end
