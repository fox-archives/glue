# shellcheck shell=bash

helper_get_wd() (
	# TODO: glue.sh to toml
	while [[ ! -f "glue.sh" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s" "$PWD"
)

helper_source_config() {
	ensure_fn_args 'helper_source_config' '1' "$@" || return

	glueFile="$1"

	ensure_file_exists "$glueFile"
	set -a
	# shellcheck disable=SC1090
	. "$glueFile"
	set +a
}

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

# this sorts an array of files by when. we assume files have a valid structure
helper_sort_files_by_when() {
	ensure_fn_args 'helper_sort_files_by_when' '1' "$@" || return

	local beforeFile duringFile afterFile

	for file; do
		if [[ $file =~ .*?-before ]]; then
			beforeFile="$file"
		elif [[ $file =~ .*?-after ]]; then
			afterFile="$file"
		else
			duringFile="$file"
		fi
	done

	for file in "$beforeFile" "$duringFile" "$afterFile"; do
		# remove whitespace
		file="$(<<< "$file" awk '{ $1=$1; print }')"

		if [[ -n $file ]]; then
			printf "%s\0" "$file"
		fi
	done
}

# run each command that is language-specific. then
# run the generic version of a particular command. for each one,
# only run the-user command file is one in 'auto' isn't present
helper_get_command_scripts() {
	ensure_fn_args 'helper_get_command_scripts' '1 2 3' "$@" || return
	local subcommand="$1"
	local langs="$2"
	local dir="$3"

	shopt -q nullglob
	shoptExitStatus="$?"
	shopt -s nullglob

	local hasRan=no

	# prepend hypthen for each language
	local newLangs
	for l in $langs; do
		newLangs+="-$l "
	done

	# the blank 'lang' represents a file like 'build-before.sh' or 'build.sh'
	for lang in $newLangs ''; do
		# a blank 'when' represents a file like 'build-go.sh' or 'build.sh'
		for when in -before '' -after; do
			# this either runs the 'auto' script or the user-override, depending
			# on whether which ones are present
			helper_run_a_relevant_script "$subcommand" "$dir" "$lang" "$when"
			if [[ $? -eq 0 ]]; then
				hasRan=yes
			fi
		done
	done

	if [[ $hasRan == no ]]; then
		die "Particular subcommand '$subcommand' did not run any files"
	fi

	(( shoptExitStatus != 0 )) && shopt -u nullglob
}

# only run a language specific version of a command
helper_get_command_and_lang_scripts() {
	ensure_fn_args 'helper_get_command_and_lang_scripts' '1 2 3' "$@" || return
	local subcommand="$1"
	local lang="$2"
	local dir="$3"
	local hasRan=no

	for when in -before '' -after; do
		# this either runs the 'auto' script or the user-override, depending
		# on whether which ones are present
		helper_run_a_relevant_script "$subcommand" "$dir" "-$lang" "$when"
		if [[ $? -eq 0 ]]; then
			hasRan=yes
		fi
	done

	if [[ $hasRan == no ]]; then
		die "Particular subcommand '$subcommand' did not run any files"
	fi
}

helper_run_a_relevant_script() {
	ensure_fn_args 'helper_run_a_relevant_script' '1 2' "$@" || return
	local subcommand="$1"
	local dir="$2"
	local lang="$3" # can be blank
	local when="$4" # can be blank

	shopt -q nullglob
	shoptExitStatus="$?"

	shopt -s nullglob

	# run the file, if it exists (override)
	local hasRanFile=no
	for file in "$dir/$subcommand$lang$when".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_error "Duplicate file '$file' should not exist"
			break
		fi

		hasRanFile=yes
		exec_file "$file"
	done

	# we ran the user file, which overrides the auto file
	# continue to next 'when' by returning
	if [[ $hasRanFile == yes ]]; then
		return
	fi

	# if no files were ran, run the auto file, if it exists
	for file in "$dir/auto/$subcommand$lang$when".*?; do
		if [[ $hasRanFile = yes ]]; then
			log_error "Duplicate file '$file' should not exist"
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
