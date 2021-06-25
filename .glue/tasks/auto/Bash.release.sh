#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

task() {
	declare -g RELEASE_STATUS=dry
	for arg; do
		case "$arg" in
			--wet)
				# shellcheck disable=SC2034
				RELEASE_STATUS=wet
		esac
	done

	if is.wet_release; then
		ensure.confirm_wet_release
	else
		log.info "Running pre-release process in dry mode"
	fi

	## 1
	ensure.git_repository_initialized
	ensure.git_only_version_changes
	ensure.git_common_history

	## 2
	# Build docs
	util.get_task 'Bash.docs.sh'
	source "$REPLY"
	ensure.exit_code_success "$REPLY"

	# Lint
	util.get_task 'Bash.lint.sh'
	source "$REPLY"
	ensure.exit_code_success "$REPLY"

	# Build
	util.get_task 'Bash.build.sh'
	source "$REPLY"
	ensure.exit_code_success "$REPLY"

	# Test
	util.get_task 'Bash.test.sh'
	source "$REPLY"
	ensure.exit_code_success "$REPLY"

	## 3
	ensure.git_only_version_changes

	util.prompt_new_version_string
	local version="$REPLY"

	hook.util.update_version_strings.bump_version() {
		local version="$1"

		# glue useAction(util-Bash-version-bump.sh)
		util.get_action 'util-Bash-version-bump.sh'
		source "$REPLY" "$version"
	}
	util.update_version_strings "$version"

	ensure.git_only_version_changes

	## 4
	# glue useAction(tool-conventional-changelog.sh)
	util.get_action 'tool-conventional-changelog.sh'
	source "$REPLY" "$version"
	local changelogFile="$REPLY"

	## 5
	# glue useAction(effect-git-tag.sh)
	util.get_action 'effect-git-tag.sh'
	source "$REPLY" "$version"

	## 6
	# glue useAction(effect-github-release.sh)
	util.get_action 'effect-github-release.sh'
	source "$REPLY" "$version" "$changelogFile"

	## 7
	# # glue useAction(result-pacman-package.sh)
	# util.get_action 'result-pacman-package.sh'
	# source "$REPLY"
}

task "$@"
unbootstrap
