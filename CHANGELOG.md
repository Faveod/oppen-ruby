# Changelog

## [unreleased]

- Trim trailing whitespaces of line_continuation when enabled.

## v1.0.0 (21-01-2025)

- Drop support for Ruby < 3.1.
- Deprarture from the `ruby/pretty_print` API with Wadler:
  - accept `indent` which will apply to `nest` and `group` implicitly if no
    `indent:` kwarg is passed.
  - accept `base_indent` which sets the base global indentation level for
    the whole printer.
  - all printing methods return `self` for call chaining.
- Wadler:
    - rename ctor param `space` to `space_gen`.
    - add `consistent` and `inconsistent` as shorthands to
    `group(:consistent)` and `group(:inconsistent)`, respectively.
    - remove args of `group_close`.
    - add `do` to avoid braking call chains.
    - `group_open` accepts a symbol `break_type` instead of a boolean.
    - add `separate` to separate a list of items.
    - add `space` to generate a literal space.
    - add `surround` as a glorified `group` that add breakables next to delimiters.

## v0.9.8 (30-12-2024)

- Oppen now supports Ruby 3.0+. It used to be restricted to Ruby 3.2+.

## v0.9.7 (05-12-2024)

- Add a new configuration flag that allows displaying without trailing whitespace. The whitespace token is also configurable.
- Add `show_print_commands` method that converts a list of tokens into its wadler printing commands.

## v0.9.6 (25-11-2024)

- Do not add indentation for empty lines.

## v0.9.5 (21-11-2024)

- Wadler:
    - update open_group helper to open inconsistent group.

## v0.9.4 (25-10-2024)

- Indent only when amount is positive.

## v0.9.3 (25-10-2024)

- Wadler:
  - add helper methods.
  - provide a group to the list of tokens if no group was created.

## v0.9.2 (25-10-2024)

- Wadler: add converter from pure tokens to Wadler calls
- Fix a stack overflow bug.

## v0.9.1 (22-10-2024)

- Increased stack capacity
- Unify naming of `margin`, `length`, and `width`, and only use `width`.
- Make `width` a named argument across different APIs.

## v0.9.0 (27-09-2024)

- Working implementation of Wadler

## v0.1.0 (13-09-2024)

- Initial working implementation
