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

	if [[ -z $lang ]]; then
		# no specific language. run everything
		do_command "$subcommand"
	else
		# run only the command specific to a language
		do_command_and_lang "$subcommand" "$lang"
	fi


}

main "$@"
