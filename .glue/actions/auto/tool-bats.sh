#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'bats'

action() {
	local -a dirs=()
	local exitCode=0

	(
		local exitCode=0

		if [ -d pkg ]; then
			if ! cd pkg; then
				error.cd_failed
			fi
			dirs=(../test ../tests)
		else
			dirs=(test tests)
		fi

		for dir in "${dirs[@]}"; do
			if [ ! -d "$dir" ]; then
				continue
			fi

			if bats --recursive --output "." "$dir"; then : else
				exitCode=$?
			fi
		done

		return "$exitCode"
	); exitCode=$?

	REPLY="$exitCode"
}

action "$@"
unbootstrap
