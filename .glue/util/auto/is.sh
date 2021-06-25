# shellcheck shell=bash

# @name is.sh
# @brief File containing functions that are only true/false checks

# @description Checks if the Git working tree is dirty. This check also pertains to untracked files
# @exitcode 0 If dirty
# @exitcode 1 If clean
is.git_working_tree_dirty() {
	local fn='is.git_working_tree_dirty'
	bootstrap.fn "$fn"

	if [ -n "$(git status --porcelain)" ]; then
		return 0
	else
		return 1
	fi

	unbootstrap.fn
}

# @description Checks if release mode is 'dry'
# @exitcode 0 if dry
# @exitcode 1 if wet
is.dry_release() {
	local fn='is.dry_release'
	bootstrap.fn "$fn"

	if [ "$RELEASE_STATUS" != 'wet' ]; then
		return 0
	else
		return 1
	fi

	unbootstrap.fn
}

# @description Checks if the release mode is 'wet'
# @exitcode 0 if wet
# @exitcode 1 if dry
is.wet_release() {
	local fn='is.wet_release'
	bootstrap.fn "$fn"

	if [ "$RELEASE_STATUS" = 'wet' ]; then
		return 0
	else
		return 1
	fi

	unbootstrap.fn
}
