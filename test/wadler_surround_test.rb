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
