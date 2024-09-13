# Creating a Release

[GitHub](https://github.com/Faveod/oppen-ruby/releases) and
[rubygems.org](https://rubygems.org/gems/oppen)
releases are automated via
[GitHub actions](./.github/workflows/release.yml)
and triggered by pushing a tag.

1. Update the [changelog](./CHANGELOG.md)
  - ⚠️ keep the `## [unreleased]` heading at the top.
1. Run the [release script](./scripts/release.sh): `scripts/release.sh v[X.Y.Z]`.
1. Push the changes: `git push origin master`
1. Check if [Continuous Integration](https://github.com/Faveod/oppen-ruby/actions)
   workflow is completed successfully.
1. Push the tags: `git push origin ref/tags/v[X.Y.Z]`
1. Wait for [Release](https://github.com/Faveod/oppen-ruby/actions)
   workflow to finish.
