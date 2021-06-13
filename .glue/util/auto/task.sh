#!/usr/bin/env bash

# @description Log the currently running task
# @noargs
# @see action.log
task.log() {
	# Path to the currently actually executing 'action' script
	# This works on the assumption that 'source's are all absolute paths
	local currentTask="${BASH_SOURCE[2]}"
	local currentTaskDirname="${currentTask%/*}"

	if [ "${currentTaskDirname##*/}" = auto ]; then
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢂  START TASK: 'auto/${currentTask##*/}'"
		else
			echo ":: => START TASK: 'auto/${currentTask##*/}'"
		fi
	else
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢂  START TASK: '${currentTask##*/}'"
		else
			echo ":: => START TASK: '${currentTask##*/}'"
		fi
	fi
}
