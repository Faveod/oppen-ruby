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

  it 'indents when using a Boolean' do
    width = 10
    block = proc { |out|
      out.separate((1..10).map(&:to_s), ',', break_type: :inconsistent, indent: true) { |i|
        out.text i
      }
    }
    assert_wadler width, <<~OUT.chomp, block, indent: 4
      1, 2, 3,
          4, 5,
          6, 7,
          8, 9,
          10
    OUT
  end

  it 'indents when using an Integer' do
    width = 10
    block = proc { |out|
      out.separate((1..10).map(&:to_s), ',', break_type: :inconsistent, indent: 2) { |i|
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

  # TODO: the rest of the params
  # 1. breaking inconsistently :before deos not make sense.
end

describe 'helpers built on separate' do
  it 'creates lines from a list' do
    width = 10
    block = proc { |out|
      out.lines((1..10).map(&:to_s), ',') { |i|
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

  it 'concatenates args from a list' do
    width = 10
    block = proc { |out|
      out.concat((1..10).map(&:to_s), ',') { |i|
        out.text i
      }
    }
    assert_wadler width, <<~OUT.chomp, block
      1,2,3,4,5,6,7,8,9,10
    OUT
  end
end
