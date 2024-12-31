# frozen_string_literal: true

require_relative 'lib'

def assert_wadler(width, expected, builder_block)
  printer = Oppen::Wadler.new(width: width)
  builder_block.(printer)
  _(printer.output).must_equal expected, 'Oppen failed the test'
end

describe 'Wadler tests' do
  describe 'must work like ruby\'s PrettyPrint library' do
    builder_block = proc { |out|
      out.group {
        out.group {
          out.group {
            out
              .group {
                out
                  .text('hello')
                  .breakable
                  .text('a')
              }
              .breakable
              .text('b')
          }
          out.breakable.text 'c'
        }
        out.breakable.text 'd'
      }
    }

    [
      [
        <<~LANG.chomp, [6]
          hello
          a
          b
          c
          d
        LANG
      ],
      [
        <<~LANG.chomp, [7, 8]
          hello a
          b
          c
          d
        LANG
      ],
      [
        <<~LANG.chomp, [9, 10]
          hello a b
          c
          d
        LANG
      ],
      [
        <<~LANG.chomp, [11, 12]
          hello a b c
          d
        LANG
      ],
      [
        <<~LANG.chomp, [13]
          hello a b c d
        LANG
      ],
    ].each do |expected, vals|
      vals.each do |width|
        it "must work with line width: #{width}" do
          assert_wadler(width, expected, builder_block)
        end
      end
    end
  end

  describe 'must work with a tree class' do
    class Tree # rubocop:disable Lint/ConstantDefinitionInBlock
      attr_reader :string
      attr_reader :children

      def initialize(string, *children)
        @string = string
        @children = children
      end

      def show(out)
        out.group {
          out
            .text(string)
            .nest(indent: string.length) {
              unless children.empty?
                out
                  .text('[')
                  .nest(indent: 1) {
                    first = true
                    children.each { |t|
                      if first
                        first = false
                      else
                        out.text(',').breakable
                      end
                      t.show(out)
                    }
                  }
                  .text ']'
              end
            }
        }
      end
    end

    builder_block = proc { |out|
      tree = Tree.new('aaaa', Tree.new('bbbbb', Tree.new('ccc'), Tree.new('dd')),
                      Tree.new('eee'), Tree.new('ffff', Tree.new('gg'),
                                                Tree.new('hhh'), Tree.new('ii')))
      tree.show(out)
    }

    [
      [
        <<~LANG.chomp, [18]
          aaaa[bbbbb[ccc,
                     dd],
               eee,
               ffff[gg,
                    hhh,
                    ii]]
        LANG
      ],
      [
        <<~LANG.chomp, [20, 22]
          aaaa[bbbbb[ccc, dd],
               eee,
               ffff[gg,
                    hhh,
                    ii]]
        LANG
      ],
      [
        <<~LANG.chomp, [23, 43]
          aaaa[bbbbb[ccc, dd],
               eee,
               ffff[gg, hhh, ii]]
        LANG
      ],
      [
        <<~LANG.chomp, [44]
          aaaa[bbbbb[ccc, dd], eee, ffff[gg, hhh, ii]]
        LANG
      ],
    ].each do |expected, vals|
      vals.each do |width|
        it "must work with line width: #{width}" do
          assert_wadler(width, expected, builder_block)
        end
      end
    end
  end

  describe 'must work with a tree class' do
    class Tree # rubocop:disable Lint/ConstantDefinitionInBlock
      def altshow(out)
        out.group {
          out.text @string
          unless @children.empty?
            out.text '['
            out.nest(indent: 2) {
              out.breakable
              first = true
              @children.each { |t|
                if first
                  first = false
                else
                  out.text ','
                  out.breakable
                end
                t.altshow(out)
              }
            }
            out.breakable
            out.text ']'
          end
        }
      end
    end

    builder_block_altshow = proc { |out|
      tree = Tree.new('aaaa', Tree.new('bbbbb', Tree.new('ccc'), Tree.new('dd')),
                      Tree.new('eee'), Tree.new('ffff', Tree.new('gg'),
                                                Tree.new('hhh'), Tree.new('ii')))
      tree.altshow(out)
    }

    [
      [
        <<~LANG.chomp, [18]
          aaaa[
            bbbbb[
              ccc,
              dd
            ],
            eee,
            ffff[
              gg,
              hhh,
              ii
            ]
          ]
        LANG
      ],
      [
        <<~LANG.chomp, [19, 20]
          aaaa[
            bbbbb[ ccc, dd ],
            eee,
            ffff[
              gg,
              hhh,
              ii
            ]
          ]
        LANG
      ],
      [
        <<~LANG.chomp, [21, 49]
          aaaa[
            bbbbb[ ccc, dd ],
            eee,
            ffff[ gg, hhh, ii ]
          ]
        LANG
      ],
      [
        <<~LANG.chomp, [50]
          aaaa[ bbbbb[ ccc, dd ], eee, ffff[ gg, hhh, ii ] ]
        LANG
      ],
    ].each do |expected, vals|
      vals.each do |width|
        it "must work with line width: #{width}" do
          assert_wadler(width, expected, builder_block_altshow)
        end
      end
    end
  end

  describe 'must work with a strict pretty example' do
    builder_block = proc { |out|
      out.group {
        out.group {
          out.nest(indent: 2) {
            out.text 'if'
            out.breakable
            out.group {
              out.nest(indent: 2) {
                out.group {
                  out.text 'a'
                  out.breakable
                  out.text '=='
                }
                out.breakable
                out.text 'b'
              }
            }
          }
        }
        out.breakable
        out.group {
          out.nest(indent: 2) {
            out.text 'then'
            out.breakable
            out.group {
              out.nest(indent: 2) {
                out.group {
                  out.text 'a'
                  out.breakable
                  out.text '<<'
                }
                out.breakable
                out.text '2'
              }
            }
          }
        }
        out.breakable
        out.group {
          out.nest(indent: 2) {
            out.text 'else'
            out.breakable
            out.group {
              out.nest(indent: 2) {
                out.group {
                  out.text 'a'
                  out.breakable
                  out.text '+'
                }
                out.breakable
                out.text 'b'
              }
            }
          }
        }
      }
    }

    [
      [
        <<~LANG.chomp, [4]
          if
            a
              ==
              b
          then
            a
              <<
              2
          else
            a
              +
              b
        LANG
      ],
      [
        <<~LANG.chomp, [5]
          if
            a
              ==
              b
          then
            a
              <<
              2
          else
            a +
              b
        LANG
      ],
      [
        <<~LANG.chomp, [6]
          if
            a ==
              b
          then
            a <<
              2
          else
            a +
              b
        LANG
      ],
      [
        <<~LANG.chomp, [7]
          if
            a ==
              b
          then
            a <<
              2
          else
            a + b
        LANG
      ],
      [
        <<~LANG.chomp, [8]
          if
            a == b
          then
            a << 2
          else
            a + b
        LANG
      ],
      [
        <<~LANG.chomp, [9]
          if a == b
          then
            a << 2
          else
            a + b
        LANG
      ],
      [
        <<~LANG.chomp, [10]
          if a == b
          then
            a << 2
          else a + b
        LANG
      ],
      [
        <<~LANG.chomp, [11, 31]
          if a == b
          then a << 2
          else a + b
        LANG
      ],
      [
        <<~LANG.chomp, [32]
          if a == b then a << 2 else a + b
        LANG
      ],
    ].each do |expected, vals|
      vals.each do |width|
        it "must work with line width: #{width}" do
          assert_wadler(width, expected, builder_block)
        end
      end
    end
  end

  describe 'must work with a tail group' do
    builder_block = proc { |out|
      out.group {
        out.group {
          out.text 'abc'
          out.breakable
          out.text 'def'
        }
        out.group {
          out.text 'ghi'
          out.breakable
          out.text 'jkl'
        }
      }
    }

    [
      [
        <<~LANG.chomp, [13]
          abc defghi
          jkl
        LANG
      ],
    ].each do |expected, vals|
      vals.each do |width|
        it "must work with line width: #{width}" do
          assert_wadler(width, expected, builder_block)
        end
      end
    end
  end

  describe 'must not break if stack is full' do
    it 'must work with a big token list' do
      wadler = Oppen::Wadler.new(width: 3)
      wadler.group(indent: 1) {
        wadler.group(indent: 1) {
          wadler.group(indent: 1) {
            wadler.group(indent: 1) {
              wadler.group(indent: 1) {
                wadler.group(indent: 1) {
                  wadler.group(indent: 1) {
                    wadler.group(indent: 1) {
                      wadler.group(indent: 1) {
                        wadler.group(indent: 1) {
                          wadler.group(indent: 1) {
                            wadler.group(indent: 1) {
                              wadler.group(indent: 1) {
                                wadler.group(indent: 1) {
                                  wadler.group(indent: 1) {
                                    wadler.group(indent: 1) {
                                      wadler.text '1 +'
                                    }
                                    wadler.breakable
                                    wadler.text '2 +'
                                  }
                                  wadler.breakable
                                  wadler.text '3 +'
                                }
                                wadler.breakable
                                wadler.text '4 +'
                              }
                              wadler.breakable
                              wadler.text '5 +'
                            }
                            wadler.breakable
                            wadler.text '6 +'
                          }
                          wadler.breakable
                          wadler.text '7 +'
                        }
                        wadler.breakable
                        wadler.text '8 +'
                      }
                      wadler.breakable
                      wadler.text '9 +'
                    }
                    wadler.breakable
                    wadler.text '10 +'
                  }
                  wadler.breakable
                  wadler.text '11 +'
                }
                wadler.breakable
                wadler.text '12 +'
              }
              wadler.breakable
              wadler.text '13 +'
            }
            wadler.breakable
            wadler.text '14 +'
          }
          wadler.breakable
          wadler.text '15 +'
        }
        wadler.breakable
        wadler.text '16'
      }
      _(wadler.output).must_equal <<~LANG.chomp
        1 +
                       2 +
                      3 +
                     4 +
                    5 +
                   6 +
                  7 +
                 8 +
                9 +
               10 +
              11 +
             12 +
            13 +
           14 +
          15 +
         16
      LANG
    end

    it 'must work with a big token list that doesn\'t overflow the scan stack' do
      wadler = Oppen::Wadler.new(width: 2)
      wadler.group {
        wadler.group {
          wadler.group {
            wadler.text 'a'
          }
        }
      }
      _(wadler.output).must_equal 'a'
    end
  end

  describe 'must work with width different from length' do
    it 'must work with a width smaller than text length' do
      builder_block = proc { |out|
        out.group {
          if out.is_a? Oppen::Wadler
            out.text('This is a long sentence', width: 1)
            out.breakable
            out.text('This is another long sentence.', width: 1)
          else
            out.text('This is a long sentence', 1)
            out.breakable
            out.text('This is another long sentence.', 1)
          end
        }
      }
      expected = 'This is a long sentence This is another long sentence.'
      assert_wadler(10, expected, builder_block)
    end

    it 'must work with a width bigger than text length' do
      builder_block = proc { |out|
        out.group {
          if out.is_a? Oppen::Wadler
            out.text('This is a small sentence', width: 500)
            out.breakable
            out.text('This is another small sentence.', width: 500)
          else
            out.text('This is a small sentence', 500)
            out.breakable
            out.text('This is another small sentence.', 500)
          end
        }
      }
      expected = <<~LANG.chomp
        This is a small sentence
        This is another small sentence.
      LANG
      assert_wadler(100, expected, builder_block)
    end

    it 'must work with a width smaller than break length' do
      builder_block = proc { |out|
        out.group {
          out.text('a')
          if out.is_a? Oppen::Wadler
            out.breakable('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', width: 1)
          else
            out.breakable('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 1)
          end
          out.text('b')
        }
      }
      expected = 'axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb'
      assert_wadler(5, expected, builder_block)
    end

    it 'must work with a width bigger than break length' do
      builder_block = proc { |out|
        out.group {
          out.text('This is a small sentence')
          if out.is_a? Oppen::Wadler
            out.breakable('. ', width: 500)
          else
            out.breakable('. ', 500)
          end
          out.text('This is another small sentence.')
        }
      }
      expected = <<~LANG.chomp
        This is a small sentence
        This is another small sentence.
      LANG
      assert_wadler(100, expected, builder_block)
    end
  end

  describe 'add group if no group was given' do
    it 'works with only a string' do
      out = Oppen::Wadler.new
      out.text 'Hello World'
      _(out.output).must_equal 'Hello World'
    end

    it 'works with only a breakable' do
      out = Oppen::Wadler.new
      out.breakable ''
      _(out.output).must_equal ''
    end

    it 'works with only a nest' do
      out = Oppen::Wadler.new
      out.nest { out.text 'Hello World' }
      _(out.output).must_equal 'Hello World'
    end

    it 'works with multiple strings and breakables' do
      out = Oppen::Wadler.new(width: 10)
      out.text 'Hello World'
      out.breakable
      out.text 'How are you doig World'
      out.breakable
      out.text 'GoodBye World'
      _(out.output).must_equal <<~LANG.chomp
        Hello World
        How are you doig World
        GoodBye World
      LANG
    end
  end

  describe 'handling empty lines' do
    it 'does not indent by default' do
      out = Oppen::Wadler.new(width: 10)
      out.group(indent: 2) {
        out.text 'a'
        out.break
        out.break
        out.text 'b'
      }

      _(out.output).must_equal <<~LANG.chomp
        a

          b
      LANG
    end

    it 'does not indent if empty first line' do
      out = Oppen::Wadler.new(width: 10)
      out.group(indent: 8) {
        out.break
        out.break
        out.text 'b'
      }

      _(out.output).must_equal <<-LANG.chomp


        b
      LANG
    end

    it 'does not indent if empty last line' do
      out = Oppen::Wadler.new(width: 10)
      out.group(indent: 2) {
        out.text 'a'
        out.break
        out.break
      }

      _(out.output).must_equal <<~LANG.chomp
        a


      LANG
    end

    it 'does not indent if empty first and last line' do
      out = Oppen::Wadler.new(width: 10)
      out.group(indent: 8) {
        out.break
        out.break
        out.break
      }

      _(out.output).must_equal "\n\n\n"
    end
  end

  describe 'Convenience methods' do
    it 'chains with calls of do' do
      out = Oppen::Wadler.new(width: 10)
      lam = -> { out.text 'from lambda' }
      out.group(indent: 8) {
        out
          .do { lam.() }
          .break
          .do { lam.() }
          .break
      }

      _(out.output).must_equal <<~OUT
        from lambda
                from lambda
      OUT
    end
  end
end
