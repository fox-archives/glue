#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

task() {
	util.extract_version_string
	local version="$REPLY"

	custom.bump_version_hook() {
		local version="$1"

		# glue useAction(util-Bash-version-bump.sh)
		util.get_action 'util-Bash-version-bump.sh'
		source "$REPLY" "$version"
	}
	util.update_version_strings "$version"

	# glue useAction(util-Bash-generate-bins.sh)
	util.get_action 'util-Bash-generate-bins.sh'
	source "$REPLY"

	# With 'set -e' enabled, the previous commands
	# were successful; otherwise, we wouldn't be here
	REPLY=0
}

task "$@"
unbootstrap
