# frozen_string_literal: true

# Oppen.
module Oppen
  # Wadler.
  class Wadler
    # @return [Config]
    #   The printer's configuration, altering its behavior.
    attr_reader :config
    # @return [Integer]
    #   the current indentation amount.
    attr_reader :current_indent
    # @return [String]
    #   the new line string, e.g. `\n`.
    attr_reader :new_line
    # @return [Object]
    #   the output string buffer. It should have a `write` and `string` methods.
    attr_reader :out
    # @return [Proc]
    #   space generator, a callable.
    attr_reader :space_gen
    # @return [Array<Token>]
    #   the tokens list that is being built.
    attr_reader :tokens
    # @return [String]
    #   the whitespace character. Used to trim trailing whitespaces.
    attr_reader :whitespace
    # @return [Integer]
    #   maximum line width.
    attr_reader :width

    # @param base_indent     [Integer]
    #   the starting indentation level for the whole printer.
    # @param config     [Config]
    #   to customize the printer's behavior.
    # @param indent     [Integer]
    #   the default indentation amount for {group} and {nest}.
    # @param new_line   [String]
    #   the new line String.
    # @param out        [Object]
    #   the output string buffer. It should have a `write` and `string` methods.
    # @param space_gen  [String, Proc]
    #   indentation string or a string generator.
    #   - If a `String`, spaces will be generated with the the lambda
    #     `->(n){ space * n }`, where `n` is the number of columns to indent.
    #   - If a `Proc`, it will receive `n` and it needs to return a `String`.
    # @param whitespace [String]       the whitespace character. Used to trim trailing whitespaces.
    # @param width      [Integer]      maximum line width desired.
    #
    # @see Token::Whitespace
    def initialize(base_indent: 0, config: Config.wadler, indent: 0, new_line: "\n",
                   out: StringIO.new, space_gen: ' ',
                   whitespace: ' ', width: 80)
      @config = config
      @current_indent = base_indent
      @indent = indent
      @new_line = new_line
      @out = out
      @space_gen = space_gen
      @tokens = []
      @whitespace = whitespace
      @width = width
    end

    # Add missing {Token::Begin}, {Token::End} or {Token::EOF}.
    #
    # @return [Nil]
    def add_missing_begin_and_end
      tokens.unshift Oppen.begin_consistent(offset: 0)
      tokens << Oppen.end
      tokens << Oppen.eof if !tokens.last.is_a?(Oppen::Token::EOF)
    end

    # Call this to extract the final pretty-printed output.
    #
    # @return [String]
    def output
      add_missing_begin_and_end
      Oppen.print(
        tokens:,
        new_line:,
        config:,
        space: space_gen,
        out:,
        width:,
      )
    end

    # Convert a list of tokens to its wadler representation.
    #
    # This method reverse engineers a tokens list to transform it into Wadler
    # printing commands. It can be particularly useful when debugging a black
    # box program.
    #
    # @option kwargs [Integer] :base_indent
    #   the base indentation amount of the output.
    # @option kwargs [String]  :printer_name
    #   the name of the Wadler instance in the output.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.text('Hello World!')
    #   out.show_print_commands(out_name: 'out')
    #
    #   # =>
    #   # out.group(:consistent, indent: 0) {
    #   #   out.text("Hello World!", width: 12)
    #   # }
    #
    # @return [String]
    def show_print_commands(**kwargs)
      add_missing_begin_and_end
      Oppen.tokens_to_wadler(tokens, **kwargs)
    end

    # Create a new group.
    #
    # @param indent    [Integer]
    #   indentation.
    # @param delim     [Nil|String|Symbol|Array<Nil, String, Symbol>]
    #   delimiters, to be printed at the start and the end of the group:
    #   - If it's nil, nothing will be printed
    #   - If it's a Strings or a Symbol, it will be printed at both positions.
    #   - If it's an Array of many items, the first two elements will be used
    #     for the start and end of the group.
    # @param break_type [Token::BreakType]
    #   break type.
    #
    # @yield
    #   the block of text in a group.
    #
    # @example 1 String Delimiter
    #   out = Oppen::Wadler.new
    #   out
    #     .text('a')
    #     .group(indent: 2, delim: '|') {
    #       out.break.text 'b'
    #     }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   #   |
    #   #   b
    #   #   |
    #
    # @example 1 Delimiter in Array
    #   out = Oppen::Wadler.new
    #   out
    #     .text('a')
    #     .group(indent: 2, delim: ['|']) {
    #       out.break.text 'b'
    #     }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   #   |
    #   #   b
    #
    # @example 2 Delimiters
    #   out = Oppen::Wadler.new
    #   out
    #     .text('a')
    #     .group(indent: 2, delim: %i[{ }]) {
    #       out.break.text 'b'
    #     }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   #   {
    #   #   b
    #   #   }
    #
    # @example Consistent Breaking
    #   out = Oppen::Wadler.new
    #   out.group(:consistent) {
    #     out.text('a').break.text('b').breakable.text('c')
    #   }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   # b
    #   # c
    #
    # @example Inconsistent Breaking
    #   out = Oppen::Wadler.new
    #   out.group(:inconsistent) {
    #     out.text('a').break.text('b').breakable.text('c')
    #   }
    #   puts out.output
    #
    #   # =>
    #   # a
    #   # b c
    #
    # @return [self]
    #
    # @see Oppen.begin_consistent
    # @see Oppen.begin_inconsistent
    def group(break_type = :consistent, delim: nil, indent: @indent)
      lft, rgt =
        case delim
        in nil then ['', '']
        in String | Symbol then [delim, delim]
        in Array then delim.values_at(0, 1).map(&:to_s)
        end

      tokens <<
        case break_type
        in :consistent
          Oppen.begin_consistent(offset: indent)
        in :inconsistent
          Oppen.begin_inconsistent(offset: indent)
        end

      if !lft.empty?
        self.break
        text lft
      end

      yield

      if !rgt.empty?
        self.break
        text rgt
      end

      tokens << Oppen.end

      self
    end

    # An alias for `group(:consistent, ...)`
    def consistent(...)
      group(:consistent, ...)
    end

    # An alias for `group(:inconsistent, ...)`
    def inconsistent(...)
      group(:inconsistent, ...)
    end

    # Create a new non-strict {group}.
    #
    # {group}s isolate breaking decisions, and in that sense they're considered
    # strict; e.g. when a breakable is transformed into an actual break, its
    # parent {group} might not get broken if the result could fit on the line.
    #
    # This is not the case with {nest}: if the same breakable was in a {nest}, the
    # {group} containing the {nest} will also be broken.
    #
    # @note indentation cannot happen if there are no breaks in the {nest}.
    #
    # @note a {nest} will not forcibly indent its content if the break type of
    # the enclosing {group} is `:inconsistent`.
    #
    # @param delim [Nil|String|Symbol|Array<Nil, String, Symbol>]
    #   delimiters, to be printed at the start and the end of the group:
    #   - `nil` is always the empty string.
    #   - If it's a Strings or a Symbol, it will be printed at both positions.
    #   - If it's an Array of many items, the first two elements will be used
    #     for the start and end of the group.
    # @param indent [Integer]
    #   indentation.
    #
    # @yield
    #   the block of text in a nest.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.nest(delim: %i[{ }], indent: 2) {
    #     out.text('a').break.text('b')
    #   }
    #   puts out.output
    #
    #   # =>
    #   # {
    #   #   a
    #   #   b
    #   # }
    #
    # @return [self]
    def nest(delim: nil, indent: @indent)
      lft, rgt =
        case delim
        in nil then ['', '']
        in String | Symbol then [delim, delim]
        in Array then delim.values_at(0, 1).map(&:to_s)
        end

      @current_indent += indent

      if !lft.empty?
        text lft
        self.break
      end

      begin
        yield
      ensure
        @current_indent -= indent
      end

      if !rgt.empty?
        self.break
        text rgt
      end

      self
    end

    # Create a new text element.
    #
    # @param value [String]
    #   the value of the token.
    #
    # @return [self]
    def text(value, width: value.length)
      if config.trim_trailing_whitespaces? && value.match(/((?:#{Regexp.escape(whitespace)})+)\z/)
        match = Regexp.last_match(1)
        matched_length = match.length
        if value.length != matched_length
          tokens << Oppen.string(value[0...-matched_length], width: width - matched_length)
        end
        tokens << Oppen.whitespace(match)
      else
        tokens << Oppen.string(value, width:)
      end
      self
    end

    # Create a new breakable element.
    #
    # @param str               [String]
    #   the value of the token that will be displayed if no new line is needed.
    # @param line_continuation [String]
    #   printed before the line break.
    # @param width             [Integer]
    #   the width of the token.
    #
    # @return [self]
    #
    # @see Wadler#break example on `line_continuation`.
    def breakable(str = ' ', line_continuation: '', width: str.length)
      if config.trim_trailing_whitespaces? && line_continuation
        line_continuation = line_continuation.sub(/(?:#{Regexp.escape(whitespace)})+\z/, '')
      end
      tokens << Oppen.break(str, width:, line_continuation:, offset: current_indent)
      self
    end

    # Create a new break element.
    #
    # @param line_continuation [String]
    #   printed before the line break.
    #
    # @example
    #   out = Oppen::Wadler.new
    #   out.text 'a'
    #   out.break
    #   out.text 'b'
    #   out.break line_continuation: '#'
    #   out.text 'c'
    #   puts out.output
    #
    #   # =>
    #   # a
    #   # b#
    #   # c
    #
    # @return [self]
    def break(line_continuation: '')
      if line_continuation && config.trim_trailing_whitespaces?
        line_continuation = line_continuation.sub(/(?:#{Regexp.escape(whitespace)})+\z/, '')
      end
      tokens << Oppen.line_break(line_continuation:, offset: current_indent)
      self
    end

    # A convenient way to avoid breaking chains of calls.
    #
    # @example
    #   out
    #     .do { fn_call(fn_arg) }
    #     .breakable
    #     .text('=')
    #     .breakable
    #     .do { fn_call(fn_arg) }
    #
    # @yield to execute the passed block
    #
    # @return [self]
    def do
      yield
      self
    end

    # A means to wrap a piece of code in several ways.
    #
    # @example
    #   out
    #     .wrap {
    #       # all printing instructions here will be deferred.
    #       # they will be executed in `when` blocks by calling the `wrapped`.
    #       out.text(...)
    #       # ...
    #     } # This is "wrapped".
    #     .when(cond1){ |wrapped|
    #       # when cond1 is true you execute this block.
    #       out.text("before wrapped")
    #       # call the wrapped
    #       wrapped.call
    #       # and continue printing
    #       out.text("after wrapped)
    #     }
    #     .when(cond2){ |wrapped|
    #       # and you cand define many conditions.
    #     }
    #     .end
    #
    # @example Calling `end` is not needed if there's another call after the last `when`:
    #   out
    #     .wrap{...} # This is "wrapped".
    #     .when(cond1){ |wrapped| ... }
    #     .when(cond2){ |wrapped| ... }
    #     .text('foo')
    #
    # @return [Wrap]
    def wrap(&blk)
      Wrap.new(blk)
    end

    # Produce a separated list.
    #
    # @example Consistent Breaking
    #  puts out.separate((1..3).map(&:to_s), ',') { |i| out.text i}
    #
    #  # =>
    #  # 1,
    #  # 2,
    #  # 3
    #
    # @example Inconsistent Breaking
    #  puts out.separate((1..3).map(&:to_s), ',', break_type: :inconsistent) { |i| out.text i}
    #
    #  # =>
    #  # 1, 2,
    #  # 3
    #
    # @param args              [String]
    #   a list of values.
    # @param sep               [String]
    #   a separator.
    # @param breakable         [String|Nil]
    #   adds a `breakable` after the separator.
    # @param break_pos         [Symbol]
    #   whether to break :before or :after the seraparator.
    # @param break_type        [Symbol|Nil]
    #   whether the break is :consistent or :inconsistent.
    #   If nil is given, the tokens will not be surrounded by a group.
    # @param indent            [Boolean|Integer]
    #   - If `true`, indent by @indent.
    #   - If an 'Integer', indent by its value.
    # @param force_break       [Boolean]
    #   adds a `break` after the separator.
    # @param line_continuation [String]
    #   string to display before new line.
    #
    # @yield to execute the passed block.
    #
    # @return [self]
    def separate(args, sep, breakable: ' ', break_pos: :after,
                 break_type: nil, indent: false,
                 force_break: false, line_continuation: '')
      if args.is_a?(Enumerator) ? args.count == 1 : args.length == 1
        yield(*args[0])
        return self
      end

      first = true
      wrap {
        wrap {
          args&.each do |*as|
            if first
              breakable '' if !line_continuation.empty? && break_pos == :after
              first = false
            elsif break_pos == :after
              text sep
              breakable(breakable, line_continuation:) if breakable && !force_break
              self.break(line_continuation:) if force_break
            else
              breakable(breakable, line_continuation:) if breakable && !force_break
              self.break(line_continuation:) if force_break
              text sep
            end
            yield(*as)
          end
        }
          .when(break_type) { |body|
            group(break_type, indent: 0) {
              body.()
            }
          }
          .end
      }
        .when(indent) { |body|
          nest(indent: indent.is_a?(Integer) ? indent : @indent) {
            body.()
          }
        }.end
      breakable('', line_continuation:) if !line_continuation.empty? && !break_type

      self
    end

    # A shorhand for `text ' '`.
    #
    # @return [self]
    def space
      text ' '
    end

    # Surround a block with +lft+ and +rgt+
    #
    # @param lft [String]  lft
    #   left surrounding string.
    # @param rgt [String]  rgt
    #   right surrounding string.
    #
    # @yield the passed block to be surrounded with `lft` and `rgt`.
    #
    # @option opts [Boolean] :group           (true)
    #   whether to create a group enclosing `lft`, `rgt`, and the passed block.
    # @option opts [Boolean] :indent          (@indent)
    #   whether to indent the passed block.
    # @option opts [String]  :lft_breakable   ('')
    #   left breakable string.
    # @option opts [Boolean] :lft_can_break   (true)
    #   injects `break` or `breakable` only if true;
    #   i.e. `lft_breakable` will be ignored if false.
    # @option opts [Boolean] :lft_force_break (false)
    #   force break instead of using `lft_breakable`.
    # @option opts [String]  :rgt_breakable   ('')
    #   right breakable string.
    # @option opts [Boolean] :rgt_can_break   (true)
    #   injects `break` or `breakable` only if true.
    #   i.e. `rgt_breakable` will be ignored if false.
    # @option opts [Boolean] :rgt_force_break (false)
    #   force break instead of using `rgt_breakable`.
    #
    # @return [self]
    def surround(lft, rgt, **opts)
      group = opts.fetch(:group, true)
      group_open(break_type: :inconsistent) if group

      text lft if lft

      indent = opts.fetch(:indent, @indent)
      nest_open(indent:)

      lft_breakable = opts.fetch(:lft_breakable, '')
      lft_can_break = opts.fetch(:lft_can_break, true)
      lft_force_break = opts.fetch(:lft_force_break, false)
      if lft && lft_can_break
        if lft_force_break
          self.break
        else
          breakable lft_breakable
        end
      end

      if block_given?
        yield
      end

      nest_close

      rgt_breakable = opts.fetch(:rgt_breakable, '')
      rgt_can_break = opts.fetch(:rgt_can_break, true)
      rgt_force_break = opts.fetch(:rgt_force_break, false)
      if rgt
        if rgt_can_break
          if rgt_force_break
            self.break
          else
            breakable rgt_breakable
          end
        end
        text rgt
      end

      group_close if group

      self
    end

    # @!group Convenience Methods Built On {separate}

    # Separate args into lines.
    #
    # This is a wrapper around {separate} where `breakable: true`.
    #
    # @see [separate]
    def lines(*args, **kwargs, &)
      separate(*args, **kwargs.merge(force_break: true), &)
    end

    # Concatenates args.
    #
    # This is a wrapper around {separate} where `breakable: false`.
    #
    # @see [separate]
    def concat(*args, **kwargs, &)
      separate(*args, **kwargs.merge(breakable: false), &)
    end

    # @!endgroup
    # @!group Convenience Methods Built On {surround}

    # YARD doesn't drop into blocks, so we can't use metaprogramming
    # to generate all these functions, so we're copy-pastring.

    # {surround} with `< >`. New lines can appear after and before the delimiters.
    #
    # @param padding [String] ('')
    #   Passed to `lft_breakable` and `rgt_breakable`.
    #
    # @return [self]
    def angles(padding: '', **kwargs, &block)
      surround(
        '<', '>',
        **kwargs.merge(lft_breakable: padding, rgt_breakable: padding),
        &block
      )
    end

    # {surround} with `< >`. New lines cannot appear after and before the delimiters.
    #
    # @return [self]
    def angles_break_both(**kwargs, &)
      angles(**kwargs.merge(lft_force_break: true, rgt_force_break: true), &)
    end

    # {surround} with `< >`. New lines will appear after and before the delimiters.
    #
    # @return [self]
    def angles_break_none(**kwargs, &)
      angles(**kwargs.merge(lft_can_break: false, rgt_can_break: false), &)
    end

    # {surround} with `{ }`. New lines can appear after and before the delimiters.
    #
    # @param padding [String] ('')
    #   Passed to `lft_breakable` and `rgt_breakable`.
    #
    # @return [self]
    def braces(padding: '', **kwargs, &block)
      surround(
        '{', '}',
        **kwargs.merge(lft_breakable: padding, rgt_breakable: padding),
        &block
      )
    end

    # {surround} with `{ }`. New lines cannot appear after and before the delimiters.
    #
    # @return [self]
    def braces_break_both(**kwargs, &)
      braces(**kwargs.merge(lft_force_break: true, rgt_force_break: true), &)
    end

    # {surround} with `{ }`. New lines will appear after and before the delimiters.
    #
    # @return [self]
    def braces_break_none(**kwargs, &)
      braces(**kwargs.merge(lft_can_break: false, rgt_can_break: false), &)
    end

    # {surround} with `[ ]`. New lines can appear after and before the delimiters.
    #
    # @param padding [String] ('')
    #   Passed to `lft_breakable` and `rgt_breakable`.
    #
    # @return [self]
    def brackets(padding: '', **kwargs, &block)
      surround(
        '[', ']',
        **kwargs.merge(lft_breakable: padding, rgt_breakable: padding),
        &block
      )
    end

    # {surround} with `[ ]`. New lines cannot appear after and before the delimiters.
    #
    # @return [self]
    def brackets_break_both(**kwargs, &)
      brackets(**kwargs.merge(lft_force_break: true, rgt_force_break: true), &)
    end

    # {surround} with `[ ]`. New lines will appear after and before the delimiters.
    #
    # @return [self]
    def brackets_break_none(**kwargs, &)
      brackets(**kwargs.merge(lft_can_break: false, rgt_can_break: false), &)
    end

    # {surround} with `( )`. New lines can appear after and before the delimiters.
    #
    # @param padding [String] ('')
    #   Passed to `lft_breakable` and `rgt_breakable`.
    #
    # @return [self]
    def parens(padding: '', **kwargs, &block)
      surround(
        '(', ')',
        **kwargs.merge(lft_breakable: padding, rgt_breakable: padding),
        &block
      )
    end

    # {surround} with `( )`. New lines cannot appear after and before the delimiters.
    #
    # @return [self]
    def parens_break_both(**kwargs, &)
      parens(**kwargs.merge(lft_force_break: true, rgt_force_break: true), &)
    end

    # {surround} with `( )`. New lines will appear after and before the delimiters.
    #
    # @return [self]
    def parens_break_none(**kwargs, &)
      parens(**kwargs.merge(lft_can_break: false, rgt_can_break: false), &)
    end

    # {surround} with `` ` ` ``. New lines cannot appear after and before the delimiters
    # unless you specify it with `rgt_can_break` and `lft_can_break`.
    #
    # @return [self]
    def backticks(**kwargs, &)
      surround('`', '`', lft_can_break: false, rgt_can_break: false, **kwargs, &)
    end

    # {surround} with `" "`. New lines cannot appear after and before the delimiters
    # unless you specify it with `rgt_can_break` and `lft_can_break`.
    #
    # @return [self]
    def quote_double(**kwargs, &)
      surround('"', '"', lft_can_break: false, rgt_can_break: false, **kwargs, &)
    end

    # {surround} with `' '`. New lines cannot appear after and before the delimiters
    # unless you specify it with `rgt_can_break` and `lft_can_break`.
    #
    # @return [self]
    def quote_single(**kwargs, &)
      surround("'", "'", lft_can_break: false, rgt_can_break: false, **kwargs, &)
    end

    # Open a consistent group.
    #
    # @param break_type [Symbol]
    #   `:consistent` or `:inconsistent`
    # @param indent     [Integer]
    #   the amount of indentation of the group.
    #
    # @return [self]
    #
    # @see Oppen.begin_consistent
    # @see Oppen.begin_inconsistent
    def group_open(break_type: :consistent, indent: 0)
      if %i[consistent inconsistent].none?(break_type)
        raise ArgumentError, '%s is not a valid type. Choose one: :consistent or :inconsistent'
      end

      tokens << Oppen.send(:"begin_#{break_type}", offset: indent)
      self
    end

    # Close a group.
    #
    # @return [self]
    def group_close
      tokens << Oppen.end
      self
    end

    # Open a consistent group and add indent amount.
    #
    # @param indent [Integer]
    #   the amount of indentation of the group.
    #
    # @return [self]
    def indent_open(indent: @indent)
      @current_indent += indent
      group_open
    end

    # Close a group and subtract indent.
    #
    # @param indent [Integer]
    #   the amount of indentation of the group.
    #
    # @return [self]
    def indent_close(indent: @indent)
      @current_indent -= indent
      group_close
    end

    # Open a nest by adding indent.
    #
    # @param indent [Integer]
    #   the amount of indentation of the nest.
    #
    # @return [self]
    def nest_open(indent: @indent)
      @current_indent += indent
      self
    end

    # Close a nest by subtracting indent.
    #
    # @param indent [Integer]
    #   the amount of indentation of the nest.
    #
    # @return [self]
    def nest_close(indent: @indent)
      @current_indent -= indent
      self
    end

    # @!endgroup

    # Helper class to allow conditional printing.
    class Wrap
      def initialize(blk)
        @wrapped = blk
        @wrapper = nil
      end

      # Conditional.
      def when(cond, &blk)
        if cond
          @wrapper = blk
        end
        self
      end

      # Flush.
      def end
        @wrapper ? @wrapper.(@wrapped) : @wrapped.()
      end

      # To re-enable chaining.
      def method_missing(meth, ...)
        self.end.send(meth, ...)
      end

      # To re-enable chaining.
      def respond_to_missing?(meth, include_private)
        self.end.respond_to_missing?(meth, include_private)
      end
    end
  end
end
