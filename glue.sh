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
			doCmd "$@"
			;;
		*)
			die "Subcommand does not exist"
			show_help
			exit 1
	esac
}

main "$@"
