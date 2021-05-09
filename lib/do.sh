# shellcheck shell=bash

doSync() {
	command -v rsync &>/dev/null || {
		die 'rsync not installed'
	}

	for dir in actions commands config; do
		mkdir -p "$GLUE_STORE/$dir/"
		mkdir -p "$WD/.glue/$dir/auto/"

		rsync -av --delete --progress "$GLUE_STORE/$dir/" "$WD/.glue/$dir/auto/"
	done
}

doCmd() {
	# source the configuration fi le
	local glueFile="$WD/glue.sh"
	util_source_config "$glueFile"

	# get subcommand, and language (if applicable)
	local subcommand lang
	subcommand="$(util_get_subcommand "$1")" || return
	lang="$(util_get_lang "$1")" || return

	local commandDir="$WD/.glue/commands"
	if [[ -z $lang ]]; then
		# no specific language. run everything
		util_get_command_scripts "$subcommand" "$GLUE_LANG" "$commandDir"
	else
		# run only the command specific to a language
		util_get_command_and_lang_scripts "$subcommand" "$lang" "$commandDir"
	fi
}
