# frozen_string_literal: true

require_relative 'lib'

describe 'separate' do
  [
    {
      title: 'does nothing for singletons',
      block: proc { |out|
        out.separate(%w[1], ',') { |i|
          out.text i
        }
      },
      expected: '1',
    },
    {
      title: 'adds separator for non-sigletons',
      block: proc { |out|
        out.separate(%w[1 2 3], ',') { |i|
          out.text i
        }
      },
      expected: '1, 2, 3',
    },
    {
      title: 'breaks consistently by default',
      block: proc { |out|
        out.separate((1..10).map(&:to_s), ',') { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
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
    },
    {
      title: 'breaks inconsistently',
      block: proc { |out|
        out.separate((1..10).map(&:to_s), ',', break_type: :inconsistent) { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        10
      OUT
    },
    {
      title: 'breaks consistently before the separator',
      block: proc { |out|
        out.separate((1..10).map(&:to_s), ',', break_pos: :before) { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
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
    },
    {
      title: 'breaks inconsistently before the separator',
      block: proc { |out|
        out.separate((1..10).map(&:to_s), ',', break_pos: :before, break_type: :inconsistent) { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
        1 ,2 ,3 ,4
        ,5 ,6 ,7
        ,8 ,9 ,10
      OUT
    },
    {
      title: 'indents when using a Boolean',
      block: proc { |out|
        out.separate((1..10).map(&:to_s), ',', break_type: :inconsistent, indent: true) { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
        1, 2, 3,
            4, 5,
            6, 7,
            8, 9,
            10
      OUT
      indent: 4,
    },
    {
      title: 'indents when using an Integer',
      block: proc { |out|
        out.separate((1..10).map(&:to_s), ',', break_type: :inconsistent, indent: 2) { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
        1, 2, 3,
          4, 5, 6,
          7, 8, 9,
          10
      OUT
    },
  ].each do |test|
    it test[:title] do
      assert_wadler 10, test[:expected], test[:block], indent: test[:indent] || 0
    end
  end
end

describe 'helpers built on separate' do
  [
    {
      title: 'creates lines from a list',
      block: proc { |out|
        out.lines((1..10).map(&:to_s), ',') { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
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
    },
    {
      title: 'concatenates args from a list',
      block: proc { |out|
        out.concat((1..10).map(&:to_s), ',') { |i|
          out.text i
        }
      },
      expected: <<~OUT.chomp,
        1,2,3,4,5,6,7,8,9,10
      OUT
    },
  ].each do |test|
    it test[:title] do
      assert_wadler 10, test[:expected], test[:block], indent: test[:indent] || 0
    end
  end
end
