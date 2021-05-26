#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'git'
ensure.cmd 'gh'

# Ensure working tree not dirty
if [ -n "$(git status --porcelain)" ]; then
	die 'Working tree still dirty. Please commit all changes before making a release'
fi

# Get current version
toml.get_key version glue-auto.toml
declare -r currentVersion="$REPLY"

# Get new version
echo "Current Version: $currentVersion"
read -rp 'New Version? ' -ei "$currentVersion"
declare -r newVersion="$REPLY"

# Ensure new version is valid (does not already exist)
if [ -n "$(git tag -l "v$newVersion")" ]; then
	# TODO: ensure there are no tag sthat exists that are greater than it
	die 'Version already exists in a Git tag'
fi

# Embed version string in application and working tree
sed -i -e "s|\(version=\"\).*\(\"\)|\1${currentVersion}\2|g" glue.toml
sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1${currentVersion}\2|g" glue.sh

# Build

# Local Release
git tag -a "v$newVersion" -m "Release $newVersion" HEAD
git push --follow-tags origin HEAD

declare -a args=()
if [ -f CHANGELOG.md ]; then
	args+=("--notes-file" "CHANGELOG.md")
elif [ -f changelog.md ]; then
	args+=("--notes-file" "changelog.md")
else
	log.warn 'CHANGELOG.md file not found. Not creating a notes file for release'
fi

# Remote Release
toml.get_key name glue.toml
projectName="${REPLY:-Release}"
gh release create "v$newVersion" --target main --title "$projectName v$newVersion" "${args[@]}"

unbootstrap
