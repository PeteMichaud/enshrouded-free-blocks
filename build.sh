#!/bin/sh
# Builds dist/free-blocks-<version>.zip, which unpacks to free-blocks/ so it
# can be dropped straight into <Enshrouded>/mods/.
set -eu

cd "$(dirname "$0")"

id=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' mod.json)
version=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' mod.json)
out="$PWD/dist/$id-$version.zip"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

mkdir -p "$stage/$id" dist
cp -R mod.json README.md LICENSE src "$stage/$id/"
[ -f icon.png ] && cp icon.png "$stage/$id/"

rm -f "$out"
(cd "$stage" && zip -rqX "$out" "$id" -x '*.DS_Store')
echo "$out"
