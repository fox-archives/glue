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

	if [[ ! -x $firstFileMatch ]]; then
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

	# the blank 'lang' represents a file like 'build-before.sh' or 'build.sh'
	local -a projectTypes=()
	for projectType; do
		projectTypes+=("$projectType.")
	done

	for projectType in "${projectTypes[@]}" ''; do
		# a blank 'when' represents a file like 'build-go.sh' or 'build.sh'
		for when in -before '' -after; do
			# this either runs the 'auto' script or the user-override, depending
			# on whether which ones are present
			helper_run_a_relevant_script "$task" "$commandDir" "$projectType" "$when"
			if [[ $? -eq 0 ]]; then
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
	ensure_fn_args 'helper_run_task_and_projectType_scripts' '1 2 3' "$@" || return
	local task="$1"
	local commandDir="$2"
	local projectType="$3"
	local hasRan=no

	for when in -before '' -after; do
		# this either runs the 'auto' script or the user-override, depending
		# on whether which ones are present
		helper_run_a_relevant_script "$task" "$commandDir" "$projectType." "$when"
		if [[ $? -eq 0 ]]; then
			hasRan=yes
		fi
	done

	if [[ $hasRan == no ]]; then
		die "Task '$task' did not match any files in directory '$commandDir'"
	fi
}

helper_run_a_relevant_script() {
	ensure_fn_args 'helper_run_a_relevant_script' '1 2' "$@" || return
	local task="$1"
	local commandDir="$2"
	local projectType="$3" # can be blank
	local when="$4" # can be blank

	shopt -q nullglob
	shoptExitStatus="$?"
	shopt -s nullglob

	# Although the following could be shortened, it's longer
	# because we checkif there are duplicate files and warn the user

	# run the file, if it exists (override)
	local hasRanFile=no
	for file in "$commandDir/${projectType}${task}${when}".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_warn "Duplicate file '$file' should not exist"
			break
		fi

		hasRanFile=yes
		exec_file "$file" "no"
	done

	# we ran the user file, which overrides the auto file
	# continue to next 'when' by returning
	if [[ $hasRanFile == yes ]]; then
		(( shoptExitStatus != 0 )) && shopt -u nullglob
		return
	fi

	# if no files were ran, run the auto file, if it exists
	# TODO: helper_get_executable_file
	for file in "$commandDir/auto/${projectType}${task}${when}".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_warn "Duplicate file '$file' should not exist"
			break
		fi

		hasRanFile=yes
		exec_file "$file" "yes"
	done

	(( shoptExitStatus != 0 )) && shopt -u nullglob

	if [[ $hasRanFile == no ]]; then
		return 1
	fi
}
