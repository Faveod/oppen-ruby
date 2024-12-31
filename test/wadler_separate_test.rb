# frozen_string_literal: true

require_relative 'lib'

describe 'separate' do
  it 'does nothing for singletons' do
    width = 10
    block = proc { |out|
      out.separate(%w[1], ',') { |i|
        out.text i
      }
    }
    assert_wadler width, '1', block
  end

  it 'adds separator for non-sigletons' do
    width = 10
    block = proc { |out|
      out.separate(%w[1 2 3], ',') { |i|
        out.text i
      }
    }
    assert_wadler width, '1, 2, 3', block
  end

  it 'breaks consistently by default' do
    width = 10
    block = proc { |out|
      out.separate((1..10).map(&:to_s), ',') { |i|
        out.text i
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10
    OUT
  end

  it 'breaks inconsistently' do
    width = 10
    block = proc { |out|
      out.separate((1..10).map(&:to_s), ',', break_type: :inconsistent) { |i|
        out.text i
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      1, 2, 3,
      4, 5, 6,
      7, 8, 9,
      10
    OUT
  end

  it 'breaks consistently before the separator' do
    width = 10
    block = proc { |out|
      out.separate((1..10).map(&:to_s), ',', break_pos: :before) { |i|
        out.text i
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      1
      ,2
      ,3
      ,4
      ,5
      ,6
      ,7
      ,8
      ,9
      ,10
    OUT
  end

  it 'breaks inconsistently before the separator' do
    width = 10
    block = proc { |out|
      out.separate((1..10).map(&:to_s), ',', break_pos: :before, break_type: :inconsistent) { |i|
        out.text i
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      1 ,2 ,3 ,4
      ,5 ,6 ,7
      ,8 ,9 ,10
    OUT
  end

  # TODO: the rest of the params
  # 1. indent doesn't work
  # 1. breaking inconsistently :before deos not make sense.
end
