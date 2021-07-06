#!/usr/bin/env bash
# TODO add -e (check for return 1's)
set -Eo pipefail
shopt -s extglob nullglob

declare PROGRAM_VERSION="0.8.0+b523e18-DIRTY"

for f in "$PROGRAM_LIB_DIR"/{commands,util}/*.sh; do
	if ! source "$f"; then
		echo "Error: Could not source file '$f' or error doing so"
		exit 1
	fi
done

main() {
	# ------------------------- Main ------------------------- #
	declare -A args=()
	source bash-args parse "$@" <<-"EOF"
	@flag [help.h] - Show help
	@flag [version.v] - Show version
	@flag [dry] - For 'run-task' and 'run-action', only show the files that would have been ran
	@arg sync - Sync changes from the Glue store to the current project. This overrides and replaces the content in 'auto' directories
	@arg list - Lists all tasks for each projectType
	@arg run-task - Execute a whole task by specifying a metaTask
	@arg run-action - Execute a particular action by specifying its name
	@arg run-file - Execute a file as if it were an action or task. This is usually only done for testing
	EOF

	if [ "${args[help]}" = yes ]; then
		echo "$argsHelpText"
		exit
	fi

	if [ "${args[version]}" = yes ]; then
		cat <<-EOF
		Version: $PROGRAM_VERSION
		EOF
		exit
	fi

	doPre() {
		set.wd
		declare GLUE_WD="$PWD"

		helper.switch_to_correct_glue_version

		util.get_config_string 'storeDir'
		GLUE_STORE="${GLUE_STORE:-${REPLY:-$HOME/.glue-store}}"

		util.get_config_array 'using'
		# shellcheck disable=SC2034
		IFS=' ' read -ra GLUE_USING <<< "${REPLIES[@]}"
	}

	# shellcheck disable=SC2154
	case "${argsCommands[0]}" in
		sync)
			doPre

			doSync "$@"
			;;
		list)
			doPre

			doList "$@"
			;;
		run-action)
			doPre

			doRunAction "$@"
			;;
		run-task)
			doPre

			doRunTask "$@"
			;;
		run-file)
			doPre

			doRunFile "$@"
			;;
		init)
			do-init "$@"
			;;
		*)
			# We run 'doPre' here because we want 'Glue' to be able to execute
			# subcommands that are valid in a future release
			doPre

			log.error "Subcommand '${argsCommands[0]}' does not exist"
			if [ -n "$argsHelpText" ]; then
				echo "$argsHelpText"
			fi
			exit 1
	esac
}

main "$@"
