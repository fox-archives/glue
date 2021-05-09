# shellcheck shell=bash

util_get_wd() (
	while ! [[ -d ".glue" ]]; do
		cd ..
	done

	printf "%s" "$PWD"
)

util_source_config() {
	ensure_fn_args 'util_source_config' '1' "$@" || return

	glueFile="$1"

	ensure_file_exists "$glueFile"
	set -a
	# shellcheck disable=SC1090
	. "$glueFile"
	set +a
}

# the name of a subcommand
util_get_subcommand() {
	ensure_fn_args 'util_get_subcommand' '1' "$@" || return

	local subcommand
	subcommand="${1%%-*}"

	printf "%s" "$subcommand"
}

# the language a subcommand is for (if any)
util_get_lang() {
	ensure_fn_args 'util_get_lang' '1' "$@" || return

	local lang="$1"

	# if there is no hypthen, then it only contains a subcommand
	if ! [[ $lang == *-* ]]; then
		printf ''
		return
	fi

	lang="${1#*-}"

	if [[ $lang == *-* ]]; then
	# if it still contains a hypthen, then it is a lang-when (ex. go-after)
		lang="${lang%%-*}"

		printf "%s" "$lang"
	else
	# no hypen, so $lang is either a lang, or when
		if [[ $lang =~ (before|after) ]]; then
			# if is a 'when', return nothing because there is no lang
			printf ''
		else
			printf "%s" "$lang"
		fi
	fi
}

# when a subcommand runs
util_get_when() {
	ensure_fn_args 'util_get_when' '1' "$@" || return

	local when="$1"

	when="${when##*-}"

	if [[ $when =~ (before|after) ]]; then
		printf "%s" "$when"
	else
		printf ''
	fi
}

# this sorts an array of files by when. we assume files have a valid structure
util_sort_files_by_when() {
	ensure_fn_args 'util_sort_files_by_when' '1' "$@" || return

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
util_get_command_scripts() {
	ensure_fn_args 'util_get_command_and_lang_scripts' '1 2 3' "$@" || return

	local subcommand="$1"
	local langs="$2"
	local dir="$3"

	shopt -q nullglob
	shoptExitStatus="$?"

	shopt -s nullglob
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
			util_run_a_relevant_script "$subcommand" "$dir" "$lang" "$when"
		done
	done


	(( shoptExitStatus != 0 )) && shopt -u nullglob
}

# only run a language specific version of a command
util_get_command_and_lang_scripts() {
	ensure_fn_args 'util_get_command_and_lang_scripts' '1 2 3' "$@" || return
	local subcommand="$1"
	local lang="$2"
	local dir="$3"

	for when in -before '' -after; do
		# this either runs the 'auto' script or the user-override, depending
		# on whether which ones are present
		util_run_a_relevant_script "$subcommand" "$dir" "-$lang" "$when"
	done
}

util_run_a_relevant_script() {
	ensure_fn_args 'util_run_a_relevant_script' '1 2' "$@" || return
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
}
