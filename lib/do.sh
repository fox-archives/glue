# shellcheck shell=bash

doSync() {
	# ------------------------- Nuke ------------------------- #
	mkdir -p "$WD"/.glue/{actions,commands,common,configs,output,state}/auto/
	find "$WD"/.glue/{actions,commands,common,configs,output}/auto/ \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -print0 \
		| xargs -r0 -- rm

	find "$WD"/.glue/{actions,commands,common,configs,output}/auto/ \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -type d -print0 \
		| xargs -r0 -- rm -rf


	# ---------------------- Directories --------------------- #
	# ACTIONS, COMMANDS, COMMON
	local dir
	for dir in actions commands common; do
		find "$GLUE_STORE/$dir/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type d -print0 \
				| xargs -r0I '{}' -- cp -r '{}' "$WD/.glue/$dir/auto/"
	done


	# ------------------------- Files ------------------------ #
	# COMMANDS:
	local projectTypeStr
	for projectType in "${GLUE_USING[@]}"; do
		projectTypeStr="${projectTypeStr}${projectType}\|"
	done
	[[ "${#GLUE_USING[@]}" -gt 0 ]] && projectTypeStr="${projectTypeStr:: -2}"

	find "$GLUE_STORE/commands/" \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -type f \
			-regextype posix-basic -regex "^.*/\($projectTypeStr\)\..*$" -print0 \
		| xargs -r0I '{}' -- cp '{}' "$WD/.glue/commands/auto/"

	# ACTIONS, CONFIGS
	# <directoryToSearchAnnotations:annotationName:directoryToSearchForFile>
	local arg
	for arg in 'commands:requireAction:actions' 'actions:requireConfig:configs'; do
		local searchDir="${arg%%:*}"
		local annotationName="${arg#*:}"; annotationName="${annotationName%:*}"
		local fileDir="${arg##*:}"

		local -a files=()
		readarray -d $'\0' files < <(find "$WD"/.glue/$searchDir/{,auto/} -ignore_readdir_race -type f \
				-exec cat {} \; \
			| sed -Ene "s/^(\s*)?(\/\/|#)(\s*)?glue(\s*)?${annotationName}\((.*?)\)$/\5/p" - \
			| sort -u \
			| tr '\n' '\0'
		)

		# 'file' is a relative path
		for file in "${files[@]}"; do
			if [ -f "$GLUE_STORE/$fileDir/$file" ]; then
				case "$file" in
				*/*)
					# If file contains a directory path in it
					mkdir -p "$WD/.glue/$fileDir/auto/${file%/*}"
					cp "$GLUE_STORE/$fileDir/$file" "$WD/.glue/$fileDir/auto/${file%/*}"
					;;
				*)
					cp "$GLUE_STORE/$fileDir/$file" "$WD/.glue/$fileDir/auto/"
				esac
			else
				log_warn "Corresponding file for annotation'$annotationName()' not found in directory '$GLUE_STORE/$fileDir'. Skipping'"
			fi
		done
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
