#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

task() {
	# glue useAction(tool-shellcheck.sh)
	util.get_action 'tool-shellcheck.sh'
	source "$REPLY"

	# glue useAction(tool-shellharden.sh)
	# util.get_action 'tool-shellharden.sh'
	# source "$REPLY"

	# shellcheck disable=SC2269
	REPLY="$REPLY"
}

task "$@"
unbootstrap
