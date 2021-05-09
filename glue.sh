#!/usr/bin/env bash

# shellcheck disable=SC2164
SRCDIR="$(dirname "$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")")"

source "$SRCDIR/lib/do.sh"
source "$SRCDIR/lib/helper.sh"
source "$SRCDIR/lib/util.sh"

# working directory
WD="$(util_get_wd)"

glueFile="$WD/glue.sh"

util_source_config "$glueFile"

main() {
	local subcommand lang

	subcommand="$(util_get_subcommand "$1")" || return
	lang="$(util_get_lang "$1")" || return

	if [[ -z $subcommand ]]; then
		die "No subcommand found"
	fi

	local dir="$PWD/.glue/commands"
	if [[ -z $lang ]]; then
		# no specific language. run everything
		util_get_command_scripts "$subcommand" "$GLUE_LANG" "$dir"
	else
		# run only the command specific to a language
		util_get_command_and_lang_scripts "$subcommand" "$lang" "$dir"
	fi


}

main "$@"
