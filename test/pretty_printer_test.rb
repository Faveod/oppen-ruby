# frozen_string_literal: true

require_relative 'lib'

describe 'PrettyPrinter tests' do
  it 'must work with an empty list' do
    list = [Oppen::Token::EOF.new]
    _(Oppen.print(tokens: list)).must_equal ''

    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]
    _(Oppen.print(tokens: list)).must_equal ''
  end

  it 'must work with a simple string' do
    list = [
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::EOF.new,
    ]
    _(Oppen.print(tokens: list)).must_equal 'XXXXXXXXXX'

    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::String.new('XXXXXXXXXX'),
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]
    _(Oppen.print(tokens: list)).must_equal 'XXXXXXXXXX'
  end

  it 'must work with string addition' do
    list = [
      Oppen::Token::Begin.new,
      *'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ'.tokens,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]

    _(Oppen.print(tokens: list, line_width: 40))
      .must_equal 'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ'
    _(Oppen.print(tokens: list, line_width: 25))
      .must_equal <<~LANG.chomp
        XXXXXXXXXX + YYYYYYYYYY +
          ZZZZZZZZZZ
      LANG
    _(Oppen.print(tokens: list, line_width: 20))
      .must_equal <<~LANG.chomp
        XXXXXXXXXX +
          YYYYYYYYYY +
          ZZZZZZZZZZ
      LANG
  end

  it 'must work with different delimiter' do
    list = [
      Oppen::Token::Begin.new,
      *'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ'.tokens,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]

    _(Oppen.print(tokens: list, line_width: 25, line_delimiter: '\n'))
      .must_equal 'XXXXXXXXXX + YYYYYYYYYY +\n  ZZZZZZZZZZ'
    _(Oppen.print(tokens: list, line_width: 20, line_delimiter: '\n'))
      .must_equal 'XXXXXXXXXX +\n  YYYYYYYYYY +\n  ZZZZZZZZZZ'
  end

  it 'must work with a string larger than line width' do
    list = [
      Oppen::Token::Begin.new,
      *'XXXXXXXXXX + YYYYYYYYYY + ZZZZZZZZZZ'.tokens,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new,
    ]

    _(Oppen.print(tokens: list, line_width: 9))
      .must_equal <<~LANG.chomp
        XXXXXXXXXX
          +
          YYYYYYYYYY
          +
          ZZZZZZZZZZ
      LANG
  end

  it 'must work with cases' do
    list = [
      Oppen::Token::Begin.new(offset: 6),
      *'cases 1 : XXXXX'.tokens, Oppen::Token::LineBreak.new,
      *'2 : YYYYY'.tokens, Oppen::Token::LineBreak.new,
      *'3 : ZZZZZ'.tokens,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new
    ]

    _(Oppen.print(tokens: list, line_width: 75))
      .must_equal <<~LANG.chomp
        cases 1 : XXXXX
              2 : YYYYY
              3 : ZZZZZ
      LANG
  end

  it 'must work with different break types' do
    list = [
      Oppen::Token::Begin.new,
      *'begin'.tokens, Oppen::Token::LineBreak.new,
      *'x := f(x);'.tokens, Oppen::Token::Break.new,
      *'y := f(y);'.tokens, Oppen::Token::Break.new,
      *'z := f(z);'.tokens, Oppen::Token::Break.new,
      *'w := f(w);'.tokens, Oppen::Token::LineBreak.new,
      *'end;'.tokens,
      Oppen::Token::End.new,
      Oppen::Token::EOF.new
    ]

    _(Oppen.print(tokens: list, line_width: 75))
      .must_equal <<~LANG.chomp
        begin
          x := f(x); y := f(y); z := f(z); w := f(w);
          end;
      LANG
    _(Oppen.print(tokens: list, line_width: 24))
      .must_equal <<~LANG.chomp
        begin
          x := f(x); y := f(y);
          z := f(z); w := f(w);
          end;
      LANG

    list[0] = Oppen::Token::Begin.new break_type: Oppen::Token::BreakType::CONSISTENT

    _(Oppen.print(tokens: list))
      .must_equal <<~LANG.chomp
        begin
          x := f(x);
          y := f(y);
          z := f(z);
          w := f(w);
          end;
      LANG
  end

  it 'must work with nested blocks' do
    list = [
      Oppen::Token::Begin.new(break_type: Oppen::Token::BreakType::CONSISTENT),

      Oppen::Token::String.new('procedure test(x, y: Integer);'), Oppen::Token::LineBreak.new,
      Oppen::Token::String.new('begin'),

      Oppen::Token::LineBreak.new(offset: 2), Oppen::Token::String.new('x:=1;'),
      Oppen::Token::LineBreak.new(offset: 2), Oppen::Token::String.new('y:=200;'),

      Oppen::Token::LineBreak.new(offset: 2), Oppen::Token::Begin.new(break_type: Oppen::Token::BreakType::CONSISTENT),
      Oppen::Token::String.new('for z:= 1 to 100 do'), Oppen::Token::LineBreak.new,
      Oppen::Token::String.new('begin'),
      Oppen::Token::LineBreak.new(offset: 2), Oppen::Token::String.new('x := x + z;'), Oppen::Token::LineBreak.new,
      Oppen::Token::String.new('end;'),
      Oppen::Token::End.new,

      Oppen::Token::LineBreak.new(offset: 2), Oppen::Token::String.new('y:=x;'), Oppen::Token::LineBreak.new,
      Oppen::Token::String.new('end;'),

      Oppen::Token::End.new,
      Oppen::Token::EOF.new
    ]

    _(Oppen.print(tokens: list, line_width: 75))
      .must_equal <<~LANG.chomp
        procedure test(x, y: Integer);
          begin
            x:=1;
            y:=200;
            for z:= 1 to 100 do
              begin
                x := x + z;
              end;
            y:=x;
          end;
      LANG
  end

  it 'must work for chaining of operators' do
    list = [
      Oppen::Token::Begin.new,
      Oppen::Token::String.new('hello'),
      Oppen::Token::Break.new(blank_space: 0), Oppen::Token::String.new('.world'),
      Oppen::Token::Break.new(blank_space: 0), Oppen::Token::String.new('.foo'),
      Oppen::Token::Break.new(blank_space: 0), Oppen::Token::String.new('.bar'),
      Oppen::Token::Break.new(blank_space: 0), Oppen::Token::String.new('.baz'),
      Oppen::Token::Break.new(blank_space: 0), Oppen::Token::String.new('.42()'),
      Oppen::Token::End.new,
      Oppen::Token::EOF.new
    ]

    _(Oppen.print(tokens: list, line_width: 20))
      .must_equal <<~LANG.chomp
        hello.world.foo.bar
          .baz.42()
      LANG

    list[0] = Oppen::Token::Begin.new(break_type: Oppen::Token::BreakType::CONSISTENT)

    _(Oppen.print(tokens: list, line_width: 20))
      .must_equal <<~LANG.chomp
        hello
          .world
          .foo
          .bar
          .baz
          .42()
      LANG
  end
end
