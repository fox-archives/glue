#!/usr/bin/env bash

# Log the currently running command
command.log() {
	# Path to the currently actually executing 'action' script
	# This works on the assumption that 'source's are all absolute paths
	local currentCommand="${BASH_SOURCE[2]}"
	local currentCommandDirname="${currentCommand%/*}"

	if [ "${currentCommandDirname##*/}" = auto ]; then
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢂  RUNNING COMMAND -> auto/${currentCommand##*/}"
		else
			echo ":: => RUNNING COMMAND -> auto/${currentCommand##*/}"
		fi
	else
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢂  RUNNING COMMAND -> ${currentCommand##*/}"
		else
			echo ":: => RUNNING COMMAND -> ${currentCommand##*/}"
		fi
	fi
}
