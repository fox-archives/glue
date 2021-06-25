# shellcheck shell=bash

# @description Bootstraps a particular 'action' or 'task' file
# @noargs
bootstrap() {
	set -eEo pipefail
	shopt -s extglob

	unset REPLY task action

	if [[ ! -v 'GLOBAL_CALLSTACK' ]]; then
		declare -g GLOBAL_CALLSTACK=
	fi

	# TODO: account for 'auto'
	local fileName="${BASH_SOURCE[1]}"
	dirName="${fileName%/*}"; dirName="${dirName/%\/auto/}";
	dirName="${dirName##*/}"; dirName="${dirName/%?/}"
	fileName="${fileName##*/}"
	bootstrap.fn "$fileName:$dirName()"

	trap 'bootstrap.trap.int' INT
	bootstrap.trap.int() {
		die 'Received SIGINT'
	}

	# 'cd' builtins might be used to change directory. This ensures
	# that we will end up back where we started
	local GLOBAL_ORIGINAL_WD="$PWD"
	trap 'bootstrap.trap.exit' EXIT
	bootstrap.trap.exit() {
		# shellcheck disable=SC2164
		cd "$GLOBAL_ORIGINAL_WD"
	}

	trap 'bootstrap.trap.err' ERR
	bootstrap.trap.err() {
		util.callstack_print
	}

	# source files in 'util'
	local dir="util"

	if shopt -q nullglob; then
		local shoptExitStatus="$?"
	else
		local shoptExitStatus="$?"
	fi
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
	# ${BASH_SOURCE[0]}: Ex. ~/.../.glue/actions/auto/util/action.sh
	# ${BASH_SOURCE[1]}: Ex. ~/.../.glue/actions/auto/util/bootstrap.sh
	# ${BASH_SOURCE[2]}: Ex. ~/.../.glue/actions/auto/do-tool-prettier-init.sh

	case "$dir" in
	actions)
		# Path to the currently actually executing 'action' script
		# This works on the assumption that 'source's are all absolute paths
		local currentAction="${BASH_SOURCE[2]}"
		local currentActionDirname="${currentAction%/*}"

		if [ "${currentActionDirname##*/}" = auto ]; then
			if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
				echo "■■■■ 🢂  START ACTION: 'auto/${currentAction##*/}'"
			else
				echo ":::: => START ACTION: 'auto/${currentAction##*/}'"
			fi
		else
			if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
				echo "■■■■ 🢂  START ACTION: '${currentAction##*/}'"
			else
				echo ":::: => START ACTION: '${currentAction##*/}'"
			fi

		fi
		;;
	tasks)
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
		echo "Context: '$0'" >&2
		echo "Context \${BASH_SOURCE[*]}: ${BASH_SOURCE[*]}" >&2
		log.error "boostrap: Directory '$dir' not supported"
		exit 1
	esac
}

# @description Bootstraps a particular function. This function is called
# within the context of 'bootstrap', so we cannot assume that any helper
# functions exist. Additionally, this function is called by other utility
# functions, so using any of those will cause a core dump due to
# infinite recursion
# @arg $1 string Name of funtion currently being bootstrapped
bootstrap.fn() {
	REPLY=

	local fnName="$1"

	if [ -z "$fnName" ]; then
		die "bootstrap.fn: Variable '$fnName' must be non zero"
	fi

	GLOBAL_CALLSTACK="$fnName${GLOBAL_CALLSTACK:+";$GLOBAL_CALLSTACK"}"
}

# @description Unbootstraps a particular function
# @arg $2 string Name of function currently being unbootstrapped
unbootstrap.fn() {
	GLOBAL_CALLSTACK="${GLOBAL_CALLSTACK#*;}"
}

# @description Prepare a directory to store generated contents. It removes
# everything from the directory if it exists, and prints info about it.
# Typically, immediately after using this function, a subshell is spawned to
# better 'isolate' any activity or execution. The following variables are set
#   - `GENERATED_DIR`: Full path to the generated directory
#   - `GENERATED_DIR_PRETTY`: The basename `GENERATED_DIR`
# @arrg $1 string Name of directory to generate. It _should_ have the same name of the file containing the callsite to this function
bootstrap.generated() {
	local fn='bootstrap.generated'
	bootstrap.fn "$fn"

	local dir="$1"

	ensure.nonZero 'dir' "$dir"

	# shellcheck disable=SC2034
	declare -g GENERATED_DIR="$GLUE_WD/.glue/generated/$dir"
	declare -g GENERATED_DIR_PRETTY="$dir"

	if [ -d "$GLUE_WD/.glue/generated/$dir" ]; then
		rm -rf "$GLUE_WD/.glue/generated/$dir"
	fi
	mkdir -p "$GLUE_WD/.glue/generated/$dir"

	if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
		echo "■■■■■■ 🢂  IN GENERATED: '$GENERATED_DIR_PRETTY'"
	else
		echo "=> IN GENERATED: '$GENERATED_DIR_PRETTY'"
	fi

	unbootstrap.fn
}

# @description Prints info that the user exited a generated directory
# @noargs
unbootstrap.generated() {
	local fn='unbootstrap.generated'
	bootstrap.fn "$fn"

	cd "$GLOBAL_ORIGINAL_WD"

	if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
		echo "■■■■■■ 🢀  OUT GENERATED: '$GENERATED_DIR_PRETTY'"
	else
		echo "<= OUT GENERATED: '$GENERATED_DIR_PRETTY'"
	fi

	unset GENERATED_DIR
	unset GENERATED_DIR_PRETTY

	unbootstrap.fn
}
