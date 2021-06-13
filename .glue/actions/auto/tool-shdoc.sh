#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

action() {
	ensure.cmd 'shdoc'

	util.shopt -s dotglob
	util.shopt -s globstar
	util.shopt -s nullglob

	local exitCode=0

	generated.in 'tool-shdoc'; (
		if [ ! -d pkg ]; then
			error.non_conforming "'./pkg' directory does not exist"
		fi

		if ! cd pkg; then
			error.cd_failed
		fi

		local exitCode=0

		for file in ./**/*.{sh,bash}; do
			local output="$GENERATED_DIR/$file"
			mkdir -p "${output%/*}"
			output="${output%.*}"
			output="$output.md"
			if shdoc < "$file" > "$output"; then : else
				if is.wet_release; then
					exitCode=$?
				fi
			fi
		done

		return "$exitCode"
	); exitCode=$?; generated.out

	REPLY="$exitCode"
}

action "$@"
unbootstrap
