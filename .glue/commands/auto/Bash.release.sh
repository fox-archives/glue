#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# Set Version
currentVersion="$(grep version glue.toml | sed 's|version="\(.*\)"|\1|g')"

echo "Current Version: $currentVersion"
read -rp 'New Version? ' -ei "$currentVersion"

echo "Input: $REPLY"
currentVersion="$REPLY"

sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1${currentVersion}\2|g" glue.sh
sed -i -e "s|\(version=\"\).*\(\"\)|\1${currentVersion}\2|g" glue.toml

# TODO: ensure version does not already exist

# Ensure working tree not dirty
if [ -n "$(git status --porcelain)" ]; then
	die 'Working tree still dirty. Please commit all changes before making a release'
fi

# Tag
git tag -a "v$currentVersion" -m "Release $currentVersion" HEAD

unbootstrap
