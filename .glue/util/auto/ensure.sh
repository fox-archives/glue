#!/usr/bin/env bash

# @description Ensures the existence of a program, terminating
# the program if it cannot be found
# @arg string Command to check in the PATH
ensure.cmd() {
	local cmd="$1"

	ensure.nonZero 'cmd' "$cmd"

	if ! command -v "$cmd" &>/dev/null; then
		die "Command '$cmd' not found"
	fi
}

# @description Checks a function's arguments, terminating the program
# if some commands were not passed
# @arg $1 string Name of function to print on error
# @arg $2 string Space separated list of numbers to check
# @arg $3 array Arguments to check
ensure.args() {
	local fnName="$1"
	local argNums="$2"
	shift; shift;

	ensure.nonZero 'fnName' "$fnName"
	ensure.nonZero 'argNums' "$argNums"

	local argNum
	for argNum in $argNums; do
		if [ -z "${!argNum}" ]; then
		# if [ -z "${@:$argNum:1}" ]; then
			echo "Context: '$0'" >&2
			echo "Context \${BASH_SOURCE[*]}: ${BASH_SOURCE[*]}" >&2
			log.error "ensure.args: Function '$fnName' has missing arguments" >&2
			exit 1
		fi
	done
}

# @description Ensures a particular argument is not empty,
# terminating the program if it is empty
# @arg $1 string Name of the variable
# @arg $2 string Value of the variable
ensure.nonZero() {
	local varName="$1"
	local varValue="$2"

	if [ -z "$varName" ] || [ $# -ne 2 ]; then
		die "ensure.nonZero: Incorrect arguments passed to 'ensure.nonZero'"
	fi

	if [ -z "$varValue" ]; then
		die "ensure.nonZero: Variable '$varName' must be non zero"
	fi
}

# @description Ensures that a file exists. If it does not,
# the program is terminated
# @arg $1 string Path of the file to check. Recommend passing an absolute path
ensure.file() {
	local fileName="$1"

	ensure.nonZero 'fileName' "$fileName"

	if [ ! -f "$fileName" ]; then
		die "ensure.file: File '$fileName' does not exist. It *must* exist"
	fi
}

# @description Ensures that a directory exists. If it does not, the
# program is terminated
# @arg $1 string Path of the directory to check. Recommend passing an absolute path
ensure.dir() {
	local dirName="$1"

	ensure.nonZero 'dirName' "$dirName"

	if [ ! -f "$dirName" ]; then
		die "ensure.dir: Directory '$dirName' does not exist. It *must* exist"
	fi
}

# @description Ensures the Git working tree is dirty. If it is not,
# and release mode is 'wet', then the program terminates
# @noargs
# @see ensure.git_working_tree_clean
ensure.git_working_tree_dirty() {
	log.ensure 'git_working_tree_clean'

	if ! is.git_working_tree_dirty; then
		local cmd
		if is.wet_release; then
			cmd="die"
		else
			cmd="log.warn"
		fi

		"$cmd" 'ensure.git_working_tree_dirty: Git working directory is clean. At this point, it *must* be dirty'
	fi
}

# @description Ensures the Git working tree is clean. If it is not,
# and the release mode is 'wet', then the program terminates
# @noargs
# @see ensure.git_working_tree_clean
ensure.git_working_tree_clean() {
	log.info 'ensure: git_working_tree_clean'

	if is.git_working_tree_dirty; then
		local cmd
		if is.wet_release; then
			cmd="die"
		else
			cmd="log.warn"
		fi

		"$cmd" 'ensure.git_working_tree_clean: Git working directory is dirty. At this point, it *must* be clean'
	fi
}

# @description Ensures the current local Git branch shares the same history
# as the remote (are ancestors). In practice, this checks if the current
# branch can be pushed to its remote counterpart without force-pushing. If
# it cannot, and the release mode is 'wet', the program terminates
# @noargs
ensure.git_common_history() {
	log.info 'ensure: git_common_history'

	local remote="${1-origin}"
	local branch="${2:-main}"


	if ! git merge-base --is-ancestor "$remote/$branch" "$branch"; then
		local cmd
		if is.wet_release; then
			cmd="die"
		else
			cmd="log.warn"
		fi

		# main NOT is the same or has new additional commits on top of origin/main"
		"$cmd" "ensure.git_common_history: Detected that your 'main' branch and it's remote have diverged. At this point, both Git branch histories *must* be shared"
	fi

}

# TODO: ensure there are no tags that exists that are greater than it
# @description Check if a version string is valid, with respect to existing
# Git version tags. If another Git commit exists with the same version, the
# program terminates
# @noargs
ensure.git_version_tag_validity() {
	log.info 'ensure: git_version_tag_validity'

	local version="$1"

	ensure.nonZero 'version' "$version"

	ensure.cmd 'git'

	if [ -n "$(git tag -l "v$version")" ]; then
		die "ensure.git_version_tag_validity: Specified version '$version' is invalid. At this point, it *must not* be an already-existing Git tag"
	fi
}

# @description Check if the current directory has a properly initialized
# Git repository. If it does not, then the program terminates
# @noargs
ensure.git_repository_initialized() {
	log.info 'ensure: git_repository_initialized'

	if [ ! -d .git ] || [ ! -f .git/HEAD ]; then
		die 'ensure.git_repository_initialized: No Git repository initialized for this directory'
	fi

	if ! git log -1 &>/dev/null; then
		die 'ensure.git_repository_initialized: At least one commit must be stored in the Git repository'
	fi
}

# @description Check if _only_ version changes are in the Git working tree. If
# changes other than version changes have been made, and the current release
# is 'wet', then terminate the program
# @noargs
ensure.git_only_version_changes() {
	log.info 'ensure: git_only_version_changes'

	# We filter 'diff' until only changed lines remains. We then
	# strip all lines that have 'version'

	# shellcheck disable=SC2143
	if [ -n "$(
		git diff --unified=0 --cached  \
		| grep '^[+-]' \
		| grep -Ev '^(--- a/|\+\+\+ b/)' \
		| grep -iv version
	)" ] || [ -n "$(
		git diff --unified=0  \
		| grep '^[+-]' \
		| grep -Ev '^(--- a/|\+\+\+ b/)' \
		| grep -iv version
	)" ]; then
		# If there is anything left in the string, it means that lines besides
		# those with 'version' in them have been changed
		local cmd
		if is.wet_release; then
			cmd="die"
		else
			cmd="log.warn"
		fi

		"$cmd" "ensure.git_only_version_changes: Changes other than version increments exist in the working tree. No changes *must* exist in the working tree with the exception of version increments"
	fi
}

# TODO: rename to version_excludes_build_string
# @description Ensure the passed version string does not have a build.
# identifier ('+566bd4d-DIRTY'). This is final check to ensure the final
# release version is correct. If the version string does have a build
# identifier, terminate the program
# @arg $1 string Versrion string to check
ensure.version_is_only_major_minor_patch() {
	log.info 'ensure: version_is_only_major_minor_patch'

	local version="$1"

	ensure.nonZero 'version' "$version"

	if [[ $version == *+* ]]; then
		die 'ensure.version_is_only_major_minor_patch: Version string contains more than just major, minor, and patch numbers'
	fi
}

# @description Ensure the user really wants to perform a 'wet' release.
# If not, then the program terminates
# @noargs
ensure.confirm_wet_release() {
	read -rei 'Do wet release? '
	if [[ "$REPLY" != *y* ]]; then
		die
	fi
}

# @description Ensure a particular exit code was successfull
# If not, and release mode is 'wet', the program terminates
# @arg $1 number Exit code
ensure.exit_code_success() {
	local exitCode="$1"

	ensure.nonZero 'exitCode' "$exitCode"

	if [ "$exitCode" -ne 0 ]; then
		local cmd
		if is.wet_release; then
			cmd="die"
		else
			cmd="log.warn"
		fi

		"$cmd" 'ensure.exit_code_success: A previous step did not exit successfully'
	fi
}
