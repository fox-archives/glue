# shellcheck shell=bash

# @description Bootstraps a particular 'action' or 'task' file
# @noargs
bootstrap() {
	set -eEo pipefail
	shopt -s extglob

	unset REPLY task action

	trap 'bootstrap.int' INT
	bootstrap.int() {
		die 'Received SIGINT'
	}

	local _original_wd="$PWD"
	trap 'bootstrap.exit' EXIT
	bootstrap.exit() {
		# shellcheck disable=SC2164
		cd "$_original_wd"
	}

	# source files in 'util'
	local dir="util"

	shopt -q nullglob
	local shoptExitStatus="$?"
	shopt -s nullglob

	local -a filesToSource=()

	# Add file in 'util' to filesToSource,
	# ensuring priority of 'override' scripts
	local file possibleFileBasename
	for file in "$GLUE_WD/.glue/$dir"/*?.sh; do
		filesToSource+=("$file")
	done

	# TODO: This sourcing does not need to be ran every time
	# Add an 'auto' file if it doesn not have a name of 'bootstrap.sh',
	# or if the name does not already exist in the filesToSource array
	for possibleFile in "$GLUE_WD/.glue/$dir/auto"/*?.sh; do
		possibleFileBasename="${possibleFile##*/}"

		if [[ $possibleFileBasename == 'bootstrap.sh' ]]; then
			continue
		fi

		# loop over exiting files that we're going to source
		# and ensure 'possibleFile' is not already there
		local alreadyThere=no
		for file in "${filesToSource[@]}"; do
			fileBasename="${file##*/}"

			# if the file is not included (which means it's not
			# already covered by 'override'), add it
			if [[ $fileBasename == "$possibleFileBasename" ]]; then
				alreadyThere=yes
			fi
		done

		if [[ $alreadyThere == no ]]; then
			filesToSource+=("$possibleFile")
		fi
	done

	if (( shoptExitStatus != 0 )); then
		shopt -u nullglob
	fi

	for file in "${filesToSource[@]}"; do
		source "$file"
	done

	local dir="${BASH_SOURCE[1]}"
	dir="${dir%/*}"
	if [ "$GLUE_IS_AUTO" ]; then
		dir="${dir%/*}"
	fi
	dir="${dir##*/}"

	# Print
	case "$dir" in
	actions)
		action.log
		;;
	tasks)
		task.log
		;;
	*)
		die "boostrap: Directory '$dir' not supported"
	esac
}

# @description 'Unbootstraps' a particular 'action' or 'task' file
# @noargs
unbootstrap() {
	unset task action

	for option in $_util_shopt_data; do
		optionValue="${option%.*}"
		optionName="${option#*.}"

		local newOptionValue
		case "$optionValue" in
			-s) newOptionValue="-u" ;;
			-u) newOptionValue="-s" ;;
		esac

		shopt "$newOptionValue" "$optionName"
	done

	_util_shopt_data=

	local dir="${BASH_SOURCE[1]}"
	dir="${dir%/*}"
	if [ "$GLUE_IS_AUTO" ]; then
		dir="${dir%/*}"
	fi
	dir="${dir##*/}"

	# Print
	case "$dir" in
	tasks)
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢀  END TASK"
		else
			echo ":: <= END TASK"
		fi

		;;
	actions)
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■■■ 🢀  END ACTION"
		else
			echo ":::: <= END ACTION"
		fi
		;;
	*)
		die "boostrap: Directory '$dir' not supported"
	esac
}
