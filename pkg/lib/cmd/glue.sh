#!/usr/bin/env bash
set -Eo pipefail

source "$GLUE_LIB_DIR/util/util.sh" || { echo "Error: Could not source file"; exit 1; }
source "$GLUE_LIB_DIR/util/get.sh" || util.source_error
source "$GLUE_LIB_DIR/util/init.sh" || util.source_error
source "$GLUE_LIB_DIR/util/log.sh" || util.source_error
source "$GLUE_LIB_DIR/do.sh" || util.source_error
source "$GLUE_LIB_DIR/helper.sh" || util.source_error

# shellcheck disable=SC2034
declare PROGRAM_VERSION="0.7.0+ad7f095-DIRTY"

set.wd
declare GLUE_WD="$PWD"

main() {
	# ----------------- Global Init (init.sh) ---------------- #
	local initFile="${GLUE_INIT_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/init.sh}"
	[[ -f $initFile ]] && source "$initFile" # exposes: store

	GLUE_STORE="${GLUE_STORE:-${store:-$HOME/.glue-store}}"
	unset -v initFile store

	# ----------------- Local Init (glue.sh) ----------------- #
	local glueFile="$GLUE_WD/glue.toml"
	# TODO: fix hack
	readonly -a GLUE_USING=("$(grep using "$glueFile" | sed 's|using[ \t]*=[ \t]*"\(.*\)"|\1|g')")
	unset -v glueFile

	# ------------------------- Main ------------------------- #
	# TODO sorry about this, will fix soon
	# HACK HACK TODO PRIORITY
	source ~/repos/bash-args/pkg/bin/args.parse  "$@" <<-"EOF"
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
			log.error "Subcommand does not exist"
			echo "$argsHelpText"
			exit 1
	esac
}

main "$@"
