#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

task() {
	local cmdName="$1"

	ensure.nonZero 'cmdName' "$cmdName"
	shift

	util.get_task 'Bash.build.sh'
	source "$REPLY"

	local -a args=()
	local append=no arg=
	for arg; do
		if [ "$append" = yes ]; then
			args+=("$arg")
		fi

		if [ "$arg" = -- ]; then
			append=yes
		fi
	done

	local execPath="$PWD/pkg/bin/$cmdName"
	if [ -f "$execPath" ]; then
		if [ -x "$execPath" ]; then
			"$execPath" "${args[@]}"
		else
			error.not_executable "$execPath"
		fi
	else
		echo "Executable file '$execPath' not found"
	fi
}

task "$@"
unbootstrap
