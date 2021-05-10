# shellcheck shell=bash

doSync() {
	command -v rsync &>/dev/null || {
		die 'rsync not installed'
	}

	# source the configuration file
	local glueFile="$WD/glue.sh"
	helper_source_config "$glueFile" # exposes: languages

	# TODO: only copy files relevant to current languages (and general ones)
	for language in $languages; do
		rsync -av --delete --progress --exclude '*-*-*' --include "*-$language-*" \
			"$GLUE_STORE/" "$WD/.glue/"
	done


}

doCmd() {
	[[ -z $1 ]] && die 'No subcommand found'

	# source the configuration file
	local glueFile="$WD/glue.sh"
	helper_source_config "$glueFile" # exposes: languages

	# get subcommand, and language (if applicable)
	local subcommand lang
	subcommand="$(helper_get_subcommand "$1")" || return
	lang="$(helper_get_lang "$1")" || return

	local commandDir="$WD/.glue/commands"
	if [[ -z $lang ]]; then
		# no specific language on cli. run all specified languages
		# as per config
		[[ -z $languages ]] && {
			die "'languages' is not set. Please specify in 'glue.sh'"
			return
		}
		helper_get_command_scripts "$subcommand" "$languages" "$commandDir"
	else


		# run only the command specific to a language
		helper_get_command_and_lang_scripts "$subcommand" "$lang" "$commandDir"
	fi
}
