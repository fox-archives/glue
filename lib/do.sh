# shellcheck shell=bash

doSync() {
	# --------------------- Copy Commands -------------------- #
	mkdir -p "$WD/.glue/commands/auto/"

	# files
	find "$WD/.glue/commands/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -print0 | xargs -r0 rm

	local projectTypeStr
	for projectType in "${GLUE_USING[@]}"; do
		projectTypeStr="${projectTypeStr}${projectType}\|"
	done
	[[ "${#GLUE_USING[@]}" -gt 0 ]] && projectTypeStr="${projectTypeStr:: -2}"

	find "$GLUE_STORE/commands/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -regextype posix-basic -regex "^.*/\($projectTypeStr\)\..*$" -print0 | xargs -r0I '{}' cp '{}' "$WD/.glue/commands/auto/"

	# directories
	find "$WD/.glue/commands/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type d -print0 | xargs -r0 rm -r
	find "$GLUE_STORE/commands/auto/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type d -print0 | xargs -r0I '{}' cp -r '{}' "$WD/.glue/commands/auto/"

	# --------------------- Copy Actions --------------------- #
	mkdir -p "$WD/.glue/actions/auto"

	local -a actionFiles
	readarray -d $'\0' actionFiles < <(find "$WD/.glue/commands/" -ignore_readdir_race -type f -exec cat {} \; \
		| sed -Ene "s/^(\s*)?(\/\/|#)(\s*)?glue(\s*)?requireAction\((.*?)\)$/\5/p" - \
		| tr '\n' '\0'
	)
	for file in "${actionFiles[@]}"; do
		cp "$GLUE_STORE/actions/auto/$file" "$WD/.glue/actions/auto"
	done

	# --------------------- Copy Configs --------------------- #
	mkdir -p "$WD/.glue/configs/auto"

	local -a configFiles
	readarray -d $'\0' configFiles < <(find "$WD/.glue/actions/" -ignore_readdir_race -type f -exec cat {} \; \
		| sed -Ene "s/^(\s*)?(\/\/|#)(\s*)?glue(\s*)?requireConfig\((.*?)\)$/\5/p" - \
		| tr '\n' '\0'
	)
	for file in "${configFiles[@]}"; do
		cp "$GLUE_STORE/configs/auto/$file" "$WD/.glue/configs/auto"
	done
}

doCmd() {
	[[ -z $1 ]] && die 'No task passed'

	# -------------- Store Init (*.boostrap.sh) -------------- #
	local commandsBootstrapFile actionsBootstrapFile

	commandsBootstrapFile="$(helper_get_executable_file "$GLUE_STORE/commands.bootstrap")"
	GLUE_COMMANDS_BOOTSTRAP="$(
		cat "$commandsBootstrapFile"
	)" || die "Could not get contents of '$commandsBootstrapFile' successfully"

	actionsBootstrapFile="$(helper_get_executable_file "$GLUE_STORE/actions.bootstrap")"
	GLUE_ACTIONS_BOOTSTRAP="$(
		cat "$actionsBootstrapFile"
	)" || die "Could not get contents of '$actionsBootstrapFile' successfully"

	# *this* task is the specific task like 'build', 'ci', etc., even though
	# we still call "$1" a 'task'
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
