# shellcheck shell=bash

util_get_gluefile() {
	printf "%s" "./glue.sh"
}

util_source_config() {
	ensure_fn_args 'util_source_config' '1' "$@"

	glueFile="$1"

	ensure_file_exists "$glueFile"
	set -a
	# shellcheck disable=SC1090
	. "$glueFile"
	set +a
}

# the name of a subcommand
util_get_subcommand() {
	ensure_fn_args 'util_get_subcommand' '1' "$@"

	local subcommand
	subcommand="${1%%-*}"

	printf "%s" "$subcommand"
}

# the language a subcommand is for (if any)
util_get_lang() {
	ensure_fn_args 'util_get_lang' '1' "$@"

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
	ensure_fn_args 'util_get_when' '1' "$@"

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
	ensure_fn_args 'util_sort_files_by_when' '1' "$@"

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

# TODO: code duplication

# run each command that is language-specific. then
# run the generic version of a particular command. for each one,
# only run the-user command file is one in 'auto' isn't present
util_get_command_scripts() {
	ensure_fn_args 'util_get_command_and_lang_scripts' '1 2 3' "$@"

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

	for lang in $newLangs ''; do
		for when in -before '' -after; do
			# run the file, if it exists (override)
			local hasRanFile=no
			for file in "$dir/$subcommand$lang$when".*?; do
				if [[ $hasRanFile = yes ]]; then
					# TODO: cleanup error
					log_error "Should not have multiple matches for subcommand '$subcommand', lang '$lang', and dir '$dir' (possible duplicate of '$file')"
					break
				fi

				hasRanFile=yes
				exec_file "$file"
			done

			# we ran the user file, which overrides the auto file
			# continue to next 'when'
			if [[ $hasRanFile == yes ]]; then
				continue
			fi

			# if no files were ran, run the auto file, if it exists
			for file in "$dir/auto/$subcommand$lang$when".*?; do
				if [[ $hasRanFile = yes ]]; then
					# TODO: cleanup error
					log_error "Should not have multiple matches for subcommand '$subcommand', lang '$lang', and dir '$dir' (possible duplicate of '$file')"
					break
				fi

				hasRanFile=yes
				exec_file "$file"
			done
		done
	done


	(( shoptExitStatus != 0 )) && shopt -u nullglob
}

# only run a language specific version of a command
util_get_command_and_lang_scripts() {
	ensure_fn_args 'util_get_command_and_lang_scripts' '1 2 3' "$@"

	local subcommand="$1"
	local lang="$2"
	local dir="$3"

	shopt -q nullglob
	shoptExitStatus="$?"

	shopt -s nullglob
	for when in -before '' -after; do
		# run the file, if it exists (override)
		local hasRanFile=no
		for file in "$dir/$subcommand-$lang$when".*?; do
			if [[ $hasRanFile = yes ]]; then
				# TODO: cleanup error
				log_error "Should not have multiple matches for subcommand '$subcommand', lang '$lang', and dir '$dir' (possible duplicate of '$file')"
				break
			fi

			hasRanFile=yes
			exec_file "$file"
		done

		# we ran the user file, which overrides the auto file
		# continue to next 'when'
		if [[ $hasRanFile == yes ]]; then
			continue
		fi

		# if no files were ran, run the auto file, if it exists
		for file in "$dir/auto/$subcommand-$lang$when".*?; do
			if [[ $hasRanFile = yes ]]; then
				# TODO: cleanup error
				log_error "Should not have multiple matches for subcommand '$subcommand', lang '$lang', and dir '$dir' (possible duplicate of '$file')"
				break
			fi

			hasRanFile=yes
			exec_file "$file"
		done
	done

	(( shoptExitStatus != 0 )) && shopt -u nullglob

	# # override
	# local -a filteredOverrideFiles=() overrideFiles=()
	# local overrideFile overrideFileSubcommand overrideFileLang

	# readarray -d $'\0' overrideFiles < <(find "$dir/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -printf "%f\0")

	# for overrideFileAndEnding in "${overrideFiles[@]}"; do
	# 	# build.sh -> build
	# 	overrideFile="${overrideFileAndEnding%.*}"
	# 	overrideFileSubcommand="$(util_get_subcommand "$overrideFile")"
	# 	overrideFileLang="$(util_get_lang "$overrideFile")"

	# 	if ! [[ $overrideFileSubcommand ]]; then
	# 		continue
	# 	fi

	# 	if ! [[ $overrideFileLang == "$lang" ]]; then
	# 		continue
	# 	fi

	# 	filteredOverrideFiles+=("$overrideFileAndEnding")
	# done

	# # auto
	# local -a filteredAutoFiles=() autoFiles=()
	# local autoFile autoFileSubcommand autoFileLang

	# readarray -d $'\0' autoFiles < <(find "$dir/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -printf "%f\0")

	# for autoFileAndEnding in "${autoFiles[@]}"; do
	# 	# build.sh -> build
	# 	autoFile="${autoFileAndEnding%.*}"
	# 	autoFileSubcommand="$(util_get_subcommand "$autoFile")"
	# 	autoFileLang="$(util_get_lang "$autoFile")"

	# 	if ! [[ $autoFileSubcommand == "$subcommand" ]]; then
	# 		continue
	# 	fi

	# 	if ! [[ $autoFileLang == "$lang" ]]; then
	# 		continue
	# 	fi

	# 	# we are here only if the language and the subcommand matches. this means
	# 	# that later, we only have to worry about the the 'auto' dir priority and
	# 	# the before/after
	# 	filteredAutoFiles+=("$autoFileAndEnding")
	# done

	# # order files

	# declare -a sortedFilteredAutoFiles
	# readarray -d $'\0' sortedFilteredAutoFiles < <(util_sort_files_by_when "${filteredAutoFiles[@]}")
	# for autoFile in "${sortedFilteredAutoFiles[@]}"; do
	# 	# filtered, and sorted
	# 	printf "FILTERED AUTO: %s\n" "$autoFile"
	# done
}
