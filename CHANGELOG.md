# Changelog

## [unreleased]

- Deprarture from the `ruby/pretty_print` API:
  - Wadler: accept base `indent` which will apply to `nest` and `group`
    implicitly if no `indent:` kwarg is passed.

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
