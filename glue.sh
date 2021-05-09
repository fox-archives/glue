#!/usr/bin/env bash

# source code directory
SRCDIR="$(dirname "$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")")" || die 'Irrecoverable failure'
source "$SRCDIR/lib/do.sh"
source "$SRCDIR/lib/helper.sh"
source "$SRCDIR/lib/util.sh"

# working directory
WD="$(helper_get_wd)" || exit

main() {
	[[ -z $1 ]] && die "No subcommand passed"

	# run init
	local initFile="${GLUE_INIT_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/init.sh}"
	[[ -f $initFile ]] && source "$initFile"

	GLUE_STORE="${GLUE_STORE:-${store:-$HOME/.glue-store}}"

	# actual subcommand to this script
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
	esac
}

main "$@"
