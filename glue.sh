#!/usr/bin/env bash
set -Eo pipefail

# source code directory
SRCDIR="$(dirname "$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")")" || die 'Irrecoverable failure'
source "$SRCDIR/lib/do.sh"
source "$SRCDIR/lib/helper.sh"
source "$SRCDIR/lib/util.sh"

# working directory
WD="$(helper_get_wd)" || exit

main() {
	GLUE_ACTIONS_DIR="$WD/.glue/actions/auto"
	GLUE_COMMANDS_DIR="$WD/.glue/commands/auto"
	GLUE_CONFIGS_DIR="$WD/.glue/configs/auto"

	# ----------------- Global Init (init.sh) ---------------- #
	local initFile="${GLUE_INIT_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/init.sh}"
	[[ -f $initFile ]] && source "$initFile" # exposes: store

	readonly GLUE_STORE="${GLUE_STORE:-${store:-$HOME/.glue-store}}"
	unset -v initFile store

	# ----------------- Local Init (glue.sh) ----------------- #
	local glueFile="$WD/glue.sh"
	[[ -f $glueFile ]] && source "$glueFile" # exposes: using

	readonly -a GLUE_USING=("${using[@]}")
	unset -v glueFile using

	# ------------------------- Main ------------------------- #
	case "$1" in
		sync)
			shift
			doSync "$@"
			;;
		cmd)
			shift

			# -------------- Store Init (*.boostrap.sh) -------------- #
			local commandsBootstrapFile actionsBootstrapFile

			commandsBootstrapFile="$(helper_get_executable_file "$GLUE_STORE/commands.bootstrap")"
			GLUE_COMMANDS_BOOTSTRAP="$(
				GLUE_ACTIONS_DIR="$GLUE_ACTIONS_DIR" \
						GLUE_COMMANDS_DIR="$GLUE_COMMANDS_DIR" \
						GLUE_CONFIGS_DIR="$GLUE_CONFIGS_DIR" \
						"$commandsBootstrapFile"
			)" || die "Could not execute '$commandsBootstrapFile' successfully"

			actionsBootstrapFile="$(helper_get_executable_file "$GLUE_STORE/actions.bootstrap")"
			GLUE_ACTIONS_BOOTSTRAP="$(
				GLUE_ACTIONS_DIR="$GLUE_ACTIONS_DIR" \
						GLUE_COMMANDS_DIR="$GLUE_COMMANDS_DIR" \
						GLUE_CONFIGS_DIR="$GLUE_CONFIGS_DIR" \
						"$actionsBootstrapFile"
			)" || die "Could not execute '$actionsBootstrapFile' successfully"

			doCmd "$@"
			;;
		*)
			die "Subcommand does not exist"
			show_help
			exit 1
	esac
}

main "$@"
