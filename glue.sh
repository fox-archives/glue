#!/usr/bin/env bash

# shellcheck disable=SC2164
DIR="$(dirname "$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")")"

. "$DIR/lib/util.sh"
. "$DIR/lib/helper.sh"

glueFile="$(util_get_gluefile)"
ensure_not_empty 'glueFile' "$glueFile"

util_source_config "$glueFile"

main() {
	local subcommand lang

	subcommand="$(util_get_subcommand "$1")"
	lang="$(util_get_variation "$1")"

	if [ -z "$subcommand" ]; then
		die "No subcommand found"
	fi

	if [ -z "$lang" ]; then
		# no specific language. run everything
		do_command "$subcommand"
	else
		# run only the command specific to a language
		do_command_and_lang "$subcommand" "$lang"
	fi


}

main "$@"
