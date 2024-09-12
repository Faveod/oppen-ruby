#!/usr/bin/env bash

set -e

if test -z "$1"
then
	echo "Please provide a tag."
	echo "Usage: scripts/release.sh v[X.Y.Z]"
	exit
fi

version=$1

echo "Preparing $version..."
# lint and test first
just lint
just test
# update the version
msg="# managed by release.sh"
sed -E -i "s/^(\s+VERSION = ).*$msg$/\1'${version#v}' $msg/" lib/oppen/version.rb
git add -A && git commit -m "release: $version"
git show
git tag -a "$version" -m "Release $version"
echo "Done!"
echo "Now push the commit (git push origin main) and the tag (git push origin refs/tags/$version)."
