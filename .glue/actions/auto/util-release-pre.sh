#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# @file util-release-pre.sh
# @brief Steps to perform before specialized version bumping
# @description This does the following
# - Ensures a clean Git working tree
# - Ensures a shared history (no force pushing)
# - Update version in 'glue-auto.toml'
# It's behavior depends on a 'RELEASE_STATUS' variable being set
# to either 'dry' or 'wet'

unset main
main() {
	ensure.cmd 'git'
	ensure.file 'glue-auto.toml'

	isDry() {
		# must be set to 'wet' to not be dry, which so
		# that it defaults to 'dry' on empty
		[ "$RELEASE_STATUS" != 'wet' ]
	}

	if isDry; then
		log.info "Running pre-release process in dry mode"
	fi

	# Ensure working tree not dirty
	if [ -n "$(git status --porcelain)" ]; then
		if isDry; then
			local cmd="log.warn"
		else
			local cmd="die"
		fi

		"$cmd" 'Working tree still dirty. Please commit all changes before making a release'
	fi

	# Ensure we can push new version and its tags changes without --force-lease
	if ! git merge-base --is-ancestor origin/main main; then
		if isDry; then
			local cmd="log.warn"
		else
			local cmd="die"
		fi

		# main NOT is the same or has new additional commits on top of origin/main"
		"$cmd" "Detected that your 'main' branch and it's remote have diverged. Won't initiate release process until histories are shared"
	fi

	# Get the new version for release. If we're dry, then just
	# use the current version, but if we are actually releasing,
	# prompt user for new version
	local newVersion=
	if isDry; then
		util.get_action 'util-get-version.sh'
		source "$REPLY"
		declare newVersion="$REPLY"
	else
		# Get current version
		toml.get_key version glue-auto.toml
		local currentVersion="$REPLY"

		# Get new version number
		# TODO: make incremenet better
		echo "Current Version: $currentVersion"
		read -rp 'New Version? ' -ei "$currentVersion"
		newVersion="$REPLY"

		# Ensure new version is valid (does not already exist)
		if [ -n "$(git tag -l "v$newVersion")" ]; then
			# TODO: ensure there are no tags that exists that are greater than it
			die 'Version already exists in a Git tag'
		fi
	fi

	# glue useAction(util-version-bump.sh)
	util.get_action 'util-version-bump.sh'
	source "$REPLY" "$newVersion"
}

main "$@"
unset main

unbootstrap
