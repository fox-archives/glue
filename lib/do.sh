# shellcheck shell=bash

do_command() {
	ensure_fn_args 'do_command' '1' "$@"

	local subcommand="$1"
	local dir="$PWD/.glue/commands"

	util_get_command_and_lang_scripts "$subcommand" "$GLUE_LANG" "$dir"
}

do_command_and_lang() {
	ensure_fn_args 'do_command_and_lang' '1 2' "$@"

	local subcommand="$1"
	local lang="$2"
	local dir="$PWD/.glue/commands"

	util_get_command_and_lang_scripts "$subcommand" "$lang" "$dir"
}
