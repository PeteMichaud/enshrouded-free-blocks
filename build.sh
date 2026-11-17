#!/bin/sh
# Builds dist/free-blocks-<version>.zip from the last commit. The zip unpacks
# to free-blocks/ so it can be dropped straight into <Enshrouded>/mods/.
# Needs only git, so it runs the same on macOS, Linux and Windows (Git Bash).
set -eu

cd "$(dirname "$0")"

id=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' mod.json)
version=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' mod.json)
out="dist/$id-$version.zip"

set -- mod.json README.md LICENSE src
if git ls-files --error-unmatch icon.png >/dev/null 2>&1; then
    set -- "$@" icon.png
fi

if ! git diff --quiet HEAD -- "$@"; then
    echo "warning: uncommitted changes are not included in the zip" >&2
fi

mkdir -p dist
git archive --format=zip --prefix="$id/" -o "$out" HEAD "$@"
echo "$PWD/$out"
