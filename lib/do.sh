# shellcheck shell=bash

doSync() {
	#
	# ─── COPY COMMANDS ──────────────────────────────────────────────────────────────
	#


	# command -v rsync &>/dev/null || {
	# 	die 'rsync not installed'
	# }
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
	[[ -n ${actualsubcommands::1} ]] && actualsubcommands="${actualsubcommands:: -1}"

	# all applicable languages
	for language in $languages; do
		langRegex+="$language|"
	done
	[[ -n ${langRegex::1} ]] && langRegex="${langRegex:: -1}"


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

	#
	# ─── COPY ACTIONS ───────────────────────────────────────────────────────────────
	#


}

doCmd() {
	[[ -z $1 ]] && die 'No task passed'

	# source the configuration file
	local glueFile="$WD/glue.sh"
	helper_source_config "$glueFile" # exposes: using

	# *this* task is the specific task like 'build', 'ci', etc., even tough
	# we still call $1 a 'task'
	local projectType task
	task="$(helper_get_task "$1")" || return
	projectType="$(helper_get_projectType "$1")" || return

	local commandDir="$WD/.glue/commands"
	if [[ -z $projectType ]]; then
		# no specific language on cli. run all specified languages
		# as per config
		[[ ! -v using ]] && {
			die "Please set 'using' in the Glue project configuration (glue.sh)"
			return
		}

		helper_run_task_scripts "$task" "$commandDir" "${using[@]}"
	else
		# run only the command specific to a language
		helper_run_task_and_projectType_scripts "$task" "$commandDir" "$projectType"
	fi
}
