# shellcheck shell=bash

# Get the current working directory of the project. We
# use this so we can get an absolute path to the current
# project (rather than being relative to `$PWD`)
helper_get_wd() (
	while [[ ! -f "glue.sh" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s" "$PWD"
)

# Return the name of the 'task'
helper_get_task() {
	ensure_fn_args 'helper_get_task' '1' "$@" || return

	local task="$1"

	task="${task##*.}"
	task="${task%%-*}"

	printf "%s" "$task"
}

# Return the name of the 'projectType'
helper_get_projectType() {
	ensure_fn_args 'helper_get_projectType' '1' "$@" || return

	local projectType="$1"

	# projectType exists iff . exists
	if [[ $projectType == *.* ]]; then
		projectType="${projectType%%.*}"
		printf "%s" "$projectType"
	else
		printf ''
		return
	fi
}

# Return the name of 'when'
helper_get_when() {
	ensure_fn_args 'helper_get_when' '1' "$@" || return

	local when="$1"

	if [[ $when == *.* ]]; then
		when="${when##*.}"
	fi

	if [[ $when == *-* ]]; then
		when="${when##*-}"
		printf "%s" "$when"
	else
		printf ''
	fi
}

# Checks to see if a valid executable exists at a location.
# For example, when passed in 'some-file', it may return 'some-file.py'
# or 'some-file.sh', depending on what is in the directory
helper_get_executable_file() {
	ensure_fn_args 'helper_get_executable_file' '1' "$@" || return
	local file="$1"

	shopt -q nullglob
	local shoptExitStatus="$?"
	shopt -s nullglob

	hasRanFile=no
	firstFileMatch=
	for aFileMatch in "$file".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_warn "Both '$aFileMatch' and '$firstFileMatch' should not exist"
			break
		fi

		hasRanFile=yes
		firstFileMatch="$aFileMatch"
	done

	(( shoptExitStatus != 0 )) && shopt -u nullglob


	if [[ -n $firstFileMatch && ! -x $firstFileMatch ]]; then
		log_warn "File '$firstFileMatch' will be executed, but it is not marked as executable"
	fi


	printf "%s" "$firstFileMatch"
}

# Run the tasks for each language, in order, according to the variable
# 'using' in `glue.sh`. Then, run the generalized version of each task
helper_run_task_scripts() {
	ensure_fn_args 'helper_run_task_scripts' '1 2 3' "$@" || return
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
			overrideFile="$(helper_get_executable_file "$commandDir/${projectType}${task}${when}")"
			autoFile="$(helper_get_executable_file "$commandDir/auto/${projectType}${task}${when}")"
			if [ -f "$overrideFile" ]; then
				exec_file "$overrideFile" "no"
				hasRan=yes
			elif [ -f "$autoFile" ]; then
				exec_file "$autoFile" "yes"
				hasRan=yes
			fi
		done
	done

	if [[ $hasRan == no ]]; then
		die "Task '$task' did not match any files in directory '$commandDir'"
	fi
}

# Run the tasks for a particular language
helper_run_task_and_projectType_scripts() {
	ensure_fn_args 'helper_run_task_and_projectType_scripts' '1 2 3' || return
	local task="$1"
	local commandDir="$2"
	local projectType="$3"

	local hasRan=no

	# a blank 'when' represents a file like 'build-go.sh' compared to 'build-go-before.sh'
	local overrideFile autoFile
	for when in -before '' -after; do
		overrideFile="$(helper_get_executable_file "$commandDir/${projectType}${task}${when}")"
		autoFile="$(helper_get_executable_file "$commandDir/auto/${projectType}${task}${when}")"
		if [ -f "$overrideFile" ]; then
			exec_file "$overrideFile" "no"
			hasRan=yes
		elif [ -f "$autoFile" ]; then
			exec_file "$autoFile" "yes"
			hasRan=yes
		fi
	done

	if [[ $hasRan == no ]]; then
		die "Task '$task' did not match any files in directory '$commandDir'"
	fi
}
