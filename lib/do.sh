# shellcheck shell=bash

doSync() {
	# --------------------- Copy Commands -------------------- #
	mkdir -p "$WD/.glue/commands/auto/"
	find "$WD/.glue/commands/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -print0 | xargs -r0 rm

	local projectTypeStr
	for projectType in "${GLUE_USING[@]}"; do
		projectTypeStr="${projectTypeStr}${projectType}\|"
	done
	[[ "${#GLUE_USING[@]}" -gt 0 ]] && projectTypeStr="${projectTypeStr:: -2}"

	find "$GLUE_STORE/commands/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -regextype posix-basic -regex "^.*/\($projectTypeStr\)\..*$" -print0 | xargs -r0I '{}' cp '{}' "$WD/.glue/commands/auto/"


	# --------------------- Copy Actions --------------------- #

}

doCmd() {
	[[ -z $1 ]] && die 'No task passed'

	# *this* task is the specific task like 'build', 'ci', etc., even tough
	# we still call $1 a 'task'
	local projectType task
	task="$(helper_get_task "$1")" || return
	projectType="$(helper_get_projectType "$1")" || return

	local commandDir="$WD/.glue/commands"
	if [[ -z $projectType ]]; then
		# no specific language on cli. run all specified languages
		# as per config
		[[ ! -v GLUE_USING ]] && {
			die "Please set 'using' in the Glue project configuration (glue.sh)"
			return
		}

		helper_run_task_scripts "$task" "$commandDir" "${GLUE_USING[@]}"
	else
		# run only the command specific to a language
		helper_run_task_and_projectType_scripts "$task" "$commandDir" "$projectType"
	fi
}
