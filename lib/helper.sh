# shellcheck shell=bash

# Checks to see if a valid executable exists at a location.
# For example, when passed in 'some-file', it may return 'some-file.py'
# or 'some-file.sh', depending on what is in the directory
helper.get_executable_file() {
	local file="$1"
	REPLY=

	if [[ -v DEBUG ]] && { :>&3; } 2>/dev/null; then
		echo "Debug: helper.get_executable_file: $file" >&3
	fi

	shopt -q nullglob
	local shoptExitStatus="$?"
	shopt -s nullglob

	hasRanFile=no
	firstFileMatch=
	for aFileMatch in "$file".*?; do
		if [[ $hasRanFile = yes ]]; then
			log.warn "Both '$aFileMatch' and '$firstFileMatch' should not exist"
			break
		fi

		hasRanFile=yes
		firstFileMatch="$aFileMatch"
	done

	(( shoptExitStatus != 0 )) && shopt -u nullglob


	if [[ -n $firstFileMatch && ! -x $firstFileMatch ]]; then
		log.warn "File '$firstFileMatch' will be executed, but it is not marked as executable"
	fi

	REPLY="$firstFileMatch"
}

# execs a file if it exists, but prints a warning if
# the file is there, but not executable
helper.exec_file() {
	file="$1"
	isAuto="$2"

	if [[ ${file::1} != / && ${file::2} != ./ ]]; then
		file="./$file"
	fi

	if [ -f "$file" ]; then
		if [ -x "$file" ]; then
			# shellcheck disable=SC2097
			GLUE_WD="$GLUE_WD" \
				GLUE_IS_AUTO="$isAuto" \
				GLUE_COMMANDS_BOOTSTRAP="$GLUE_COMMANDS_BOOTSTRAP" \
				GLUE_ACTIONS_BOOTSTRAP="$GLUE_ACTIONS_BOOTSTRAP" \
				"$file"
			return
		else
			die "File '$file' exists, but is not executable. Bailing early to prevent out of order execution"
		fi
	else
		log.error "Could not exec file '$file' because it does not exist"
	fi
}


# Run the tasks for each language, in order, according to the variable
# 'using' in `glue.sh`. Then, run the generalized version of each task
helper.run_task_scripts() {
	local task="$1"
	local commandDir="$2"
	shift; shift

	local hasRan=no

	local -a projectTypes=()
	for projectType; do
		projectTypes+=("$projectType.")
	done

	# a blank 'projectType' represents a file like 'build.sh' compared to 'NodeJS_Server.build.sh'
	for projectType in "${projectTypes[@]}" ''; do
		# a blank 'when' represents a file like 'build-go.sh' compared to 'build-go-before.sh'
		local overrideFile autoFile
		for when in -before '' -after; do
			overrideFile="$(helper.get_executable_file "$commandDir/${projectType}${task}${when}")"
			autoFile="$(helper.get_executable_file "$commandDir/auto/${projectType}${task}${when}")"
			if [ -f "$overrideFile" ]; then
				helper.exec_file "$overrideFile" "no"
				hasRan=yes
			elif [ -f "$autoFile" ]; then
				helper.exec_file "$autoFile" "yes"
				hasRan=yes
			fi
		done
	done

	if [[ $hasRan == no ]]; then
		die "Task '$task' did not match any files in directory '$commandDir'"
	fi
}

# Run the tasks for a particular language
helper.run_task_and_projectType_scripts() {
	local task="$1"
	local commandDir="$2"
	local projectType="$3"

	local hasRan=no

	if [ -n "$task" ]; then
		task=".$task"
	fi

	# a blank 'when' represents a file like 'build-go.sh' compared to 'build-go-before.sh'
	local overrideFile autoFile
	for when in -before '' -after; do
		helper.get_executable_file "$commandDir/${projectType}${task}${when}"
		overrideFile="$REPLY"

		helper.get_executable_file "$commandDir/auto/${projectType}${task}${when}"
		autoFile="$REPLY"

		if [ -f "$overrideFile" ]; then
			helper.exec_file "$overrideFile" "no"
			hasRan=yes
		elif [ -f "$autoFile" ]; then
			helper.exec_file "$autoFile" "yes"
			hasRan=yes
		fi
	done

	if [[ $hasRan == no ]]; then
	echo "$projectType"
	echo "$task"
	echo "$when"
		printf -v msg "%s\n    -> %s\n    -> %s\nExiting" "Meta task '$task' did not match any files in the following directories" ".glue/commands/auto" ".glue/commands"
		log.error "$msg"
	fi
}
