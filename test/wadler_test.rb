# frozen_string_literal: true

require 'prettyprint'

require_relative 'lib'

def check_roundtrip(margin, expected, builder_block)
  printer = Oppen::Wadler.new(margin:)
  builder_block.call(printer)
  _(printer.output).must_equal expected, 'Oppen failed the test'

  printer = PrettyPrint.new(''.dup, margin)
  builder_block.call(printer)
  printer.flush
  _(printer.output).must_equal expected, 'PrettyPrint failed the test'
end

describe 'Wadler tests' do
  describe 'must work like ruby\'s PrettyPrint library' do
    builder_block = proc { |out|
      out.group {
        out.group {
          out.group {
            out.group {
              out.text 'hello'
              out.breakable
              out.text 'a'
            }
            out.breakable
            out.text 'b'
          }
          out.breakable
          out.text 'c'
        }
        out.breakable
        out.text 'd'
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
      vals.each do |margin|
        it "must work with line width: #{margin}" do
          check_roundtrip(margin, expected, builder_block)
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
          out.text string
          out.nest(string.length) {
            unless children.empty?
              out.text '['
              out.nest(1) {
                first = true
                children.each { |t|
                  if first
                    first = false
                  else
                    out.text ','
                    out.breakable
                  end
                  t.show(out)
                }
              }
              out.text ']'
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
      vals.each do |margin|
        it "must work with line width: #{margin}" do
          check_roundtrip(margin, expected, builder_block)
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
            out.nest(2) {
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
      vals.each do |margin|
        it "must work with line width: #{margin}" do
          check_roundtrip(margin, expected, builder_block_altshow)
        end
      end
    end
  end

  describe 'must work with a strict pretty example' do
    builder_block = proc { |out|
      out.group {
        out.group {
          out.nest(2) {
            out.text 'if'
            out.breakable
            out.group {
              out.nest(2) {
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
          out.nest(2) {
            out.text 'then'
            out.breakable
            out.group {
              out.nest(2) {
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
          out.nest(2) {
            out.text 'else'
            out.breakable
            out.group {
              out.nest(2) {
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
      vals.each do |margin|
        it "must work with line width: #{margin}" do
          check_roundtrip(margin, expected, builder_block)
        end
      end
    end
  end
end
