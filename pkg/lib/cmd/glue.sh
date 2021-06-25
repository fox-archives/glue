#!/usr/bin/env bash
set -Eo pipefail
shopt -s extglob

source "$PROGRAM_LIB_DIR/util/util.sh" || { echo "Error: Could not source file"; exit 1; }
source "$PROGRAM_LIB_DIR/util/get.sh" || util.source_error
source "$PROGRAM_LIB_DIR/util/init.sh" || util.source_error
source "$PROGRAM_LIB_DIR/util/log.sh" || util.source_error
source "$PROGRAM_LIB_DIR/do.sh" || util.source_error
source "$PROGRAM_LIB_DIR/helper.sh" || util.source_error

# shellcheck disable=SC2034
declare PROGRAM_VERSION="0.8.0+c44d07c-DIRTY"

set.wd
# shellcheck disable=SC2034
declare GLUE_WD="$PWD"

main() {
	util.get_config_string 'storeDir'
	GLUE_STORE="${GLUE_STORE:-${REPLY:-$HOME/.glue-store}}"

	util.get_config_array 'using'
	echo v "${REPLIES[@]}"
	IFS=' ' read -ra GLUE_USING <<< "${REPLIES[@]}"

	util.get_toml_string "$GLUE_WD/glue-auto.toml" 'glueVersion'
	if [ "$REPLY" != 'latest' ]; then
		die "Glue requires a 'glueVersion' key set to 'latest'. Specific versions are not supported yet"
	fi


	# ------------------------- Main ------------------------- #
	source args.parse "$@" <<-"EOF"
	@flag [help.h] - Show help
	@flag [version.v] - Show version
	@arg sync - Sync changes from the Glue store to the current project. This overrides and replaces the content in 'auto' directories
	@arg list - Lists all projectTypes of the current project
	@arg print - Prints the script about to be executed
	@arg act - Executes an action
	@arg cmd - Execute a meta task (command)
	EOF

	if [[ -v '${args[help]}' ]]; then
		echo "$argsHelpText"
		exit
	fi

	if [[ -v '${args[version]}' ]]; then
		util.show_version
		exit
	fi

	case "${argsCommands[0]}" in
		sync)
			doSync "$@"
			;;
		list)
			doList "$@"
			;;
		print)
			doPrint "$@"
			;;
		act)
			doAct "$@"
			;;
		cmd)
			doCmd "$@"
			;;
		*)
			log.error "Subcommand '${argsCommands[0]}' does not exist"
			if [ -n "$argsHelpText" ]; then
				echo "$argsHelpText"
			fi
			exit 1
	esac
}

main "$@"
