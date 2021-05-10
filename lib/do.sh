# shellcheck shell=bash

doSync() {
	command -v rsync &>/dev/null || {
		die 'rsync not installed'
	}
	# TODO: cleanup
	# source the configuration file
	local glueFile="$WD/glue.sh"
	helper_source_config "$glueFile" # exposes: languages

	# all applicable subcommands
	local -a allFiles=()
	readarray -d $'\0' allFiles < <(find "$GLUE_STORE/commands/auto" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -printf "%f\0")
	actualsubcommands=
	for file in "${allFiles[@]}"; do
		file="${file%%.*}"
		file="${file%%-*}"

		if ! [[ $actualsubcommands =~ ((^|\|)$file\|) ]]; then
			actualsubcommands+="$file|"
		fi

	done
	actualsubcommands="${actualsubcommands:: -1}"

	# all applicable languages
	for language in $languages; do
		langRegex+="$language|"
	done
	langRegex="${langRegex:: -1}"


	find "$WD/.glue/commands" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -print0 | xargs -r0 rm
	find "$GLUE_STORE/commands/auto" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -regextype posix-egrep -regex "^.*/($actualsubcommands)?(-($langRegex))?(-(before|after))?\..*?$" -print0 | xargs -r0I '{}' cp '{}' "$WD/.glue/commands"

	# find "$GLUE_STORE/commands/auto" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -printf '%f\0' | perl -e "$(cat <<-"EOF"
	# use strict;
	# use warnings;

	# my $input = do { local $/; <STDIN> };
	# my @array = split('\0', $input);
	# my $langRegex = "nodeapp|java";

	# foreach(@array) {
	# 	if ($_ =~ /(build|deploy)(-($langRegex))?(-before|-after)?\..*?$/) {
	# 		print "$_\n";
	# 	}
	# }
	# EOF
	# )"

	# for language in $languages; do
	# 	rsync -acv --delete --progress --exclude '*-*-*' --include "*-$language-*" \
	# 		"$GLUE_STORE/commands" "$WD/.glue/commands"
	# done


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
