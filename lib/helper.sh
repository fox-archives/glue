# shellcheck shell=bash

helper_get_wd() (
	while [[ ! -f "glue.sh" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s" "$PWD"
)

# the name of a task of a particular projectType
helper_get_task() {
	ensure_fn_args 'helper_get_task' '1' "$@" || return

	local task="$1"

	task="${task##*.}"
	task="${task%%-*}"

	printf "%s" "$task"
}

# the identifier of the script aggregation
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

# when a subcommand runs
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

# run each command that is language-specific. then
# run the generic version of a particular command. for each one,
# only run the-user command file is one in 'auto' isn't present
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

# only run a language specific version of a command
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

	# although the following could be shortened, it is a bit more verbose
	# so we can check if there are duplicate files and warn the user

	# run the file, if it exists (override)
	local hasRanFile=no
	for file in "$commandDir/${projectType}${task}${when}".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_warn "Duplicate file '$file' should not exist"
			break
		fi

		hasRanFile=yes
		exec_file "$file"
	done

	# we ran the user file, which overrides the auto file
	# continue to next 'when' by returning
	if [[ $hasRanFile == yes ]]; then
		(( shoptExitStatus != 0 )) && shopt -u nullglob
		return
	fi

	# if no files were ran, run the auto file, if it exists
	for file in "$commandDir/auto/${projectType}${task}${when}".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_warn "Duplicate file '$file' should not exist"
			break
		fi

		hasRanFile=yes
		exec_file "$file"
	done

	(( shoptExitStatus != 0 )) && shopt -u nullglob

	if [[ $hasRanFile == no ]]; then
		return 1
	fi
}
