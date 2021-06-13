#!/usr/bin/env bash

# @name generated.sh
# @brief File contaning functions that are only for `.glue/generated`

# @description Prepare a directory to store generated contents. It removes
# everything from the directory if it exists, and prints info about it.
# Typically, immediately after using this function, a subshell is spawned to
# better 'isolate' any activity or execution. The following variables are set
#   - `GENERATED_DIR`: Full path to the generated directory
#   - `GENERATED_DIR_PRETTY`: The basename `GENERATED_DIR`
# @arrg $1 string Name of directory to generate. It _should_ have the same name of the file containing the callsite to this function
generated.in() {
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
}

# @description Prints info that the user exited a generated directory
# @noargs
generated.out() {
	if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
		echo "■■■■■■ 🢀  OUT GENERATED: '$GENERATED_DIR_PRETTY'"
	else
		echo "<= OUT GENERATED: '$GENERATED_DIR_PRETTY'"
	fi
}
