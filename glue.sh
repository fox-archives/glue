#!/usr/bin/env bash
set -Eo pipefail

# source code directory
GLUE_ROOT_DIR="$(readlink -f "${BASH_SOURCE[0]}")" || die 'Irrecoverable failure'
GLUE_ROOT_DIR="${GLUE_ROOT_DIR%/*}"
source "$GLUE_ROOT_DIR/lib/util/util.sh" || { echo "Erorr: Could not source file"; exit 1; }
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

	readonly GLUE_STORE="${GLUE_STORE:-${store:-$HOME/.glue-store}}"
	unset -v initFile store

	# ----------------- Local Init (glue.sh) ----------------- #
	local glueFile="$GLUE_WD/glue.sh"
	[[ -f $glueFile ]] && source "$glueFile" # exposes: using

	readonly -a GLUE_USING=("${using[@]}")
	unset -v glueFile using

	# ------------------------- Main ------------------------- #
	for arg; do
		case "$arg" in
			(-h|--help) util_show_help; exit ;;
			(-v|--version) util_show_version; exit
		esac
	done

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
			log.error "Subcommand does not exist"
			util.show_help
			exit 1
	esac
}

main "$@"
