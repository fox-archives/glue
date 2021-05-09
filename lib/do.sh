# shellcheck shell=bash

do_command() {
	:
}

do_command_and_lang() {
	ensure_fn_args 'util_source_command_variation' '1 2' "$@"

	local subcommand="$1"
	local lang="$2"

	util_get_command_and_lang_scripts "$subcommand" "$lang"
}
