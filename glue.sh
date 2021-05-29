#!/usr/bin/env bash
set -Eo pipefail

# shellcheck disable=SC2034
declare PROGRAM_VERSION="0.7.0"

# source code directory
GLUE_ROOT_DIR="$(readlink -f "${BASH_SOURCE[0]}")" || die 'Irrecoverable failure'
GLUE_ROOT_DIR="${GLUE_ROOT_DIR%/*}"
source "$GLUE_ROOT_DIR/lib/util/util.sh" || { echo "Error: Could not source file"; exit 1; }
source "$GLUE_ROOT_DIR/lib/util/get.sh" || util.source_error
source "$GLUE_ROOT_DIR/lib/util/init.sh" || util.source_error
source "$GLUE_ROOT_DIR/lib/util/log.sh" || util.source_error
source "$GLUE_ROOT_DIR/lib/do.sh" || util.source_error
source "$GLUE_ROOT_DIR/lib/helper.sh" || util.source_error

set.wd
GLUE_WD="$PWD"

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
	source "$(basher package-path eankeen/args)/bin/args-init"
	args.parse "$@" <<-"EOF"
	@flag [help.h] - Show help
	@flag [version.v] - Show version
	@arg sync - Sync changes from the Glue store to the current project. This overrides and replacles the content in 'auto' directories
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
