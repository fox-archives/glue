# shellcheck shell=bash

doSync() {
	# ------------------------- Nuke ------------------------- #
	mkdir -p "$GLUE_WD"/.glue/{actions,commands,common,configs,output,state}/auto/
	find "$GLUE_WD"/.glue/{actions,commands,common,configs,output}/auto/ \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -print0 \
		| xargs -r0 -- rm

	find "$GLUE_WD"/.glue/{actions,commands,common,configs,output}/auto/ \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -type d -print0 \
		| xargs -r0 -- rm -rf


	# ---------------------- Directories --------------------- #
	# ACTIONS, COMMANDS, COMMON
	local dir
	for dir in actions commands common; do
		find "$GLUE_STORE/$dir/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type d -print0 \
				| xargs -r0I '{}' -- cp -r '{}' "$GLUE_WD/.glue/$dir/auto/"
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
		| xargs -r0I '{}' -- cp '{}' "$GLUE_WD/.glue/commands/auto/"

	# ACTIONS, CONFIGS
	# <directoryToSearchAnnotations:annotationName:directoryToSearchForFile>
	local arg
	for arg in 'commands:requireAction:actions' 'actions:requireConfig:configs'; do
		local searchDir="${arg%%:*}"
		local annotationName="${arg#*:}"; annotationName="${annotationName%:*}"
		local fileDir="${arg##*:}"

		local -a files=()
		readarray -d $'\0' files < <(find "$GLUE_WD"/.glue/$searchDir/{,auto/} -ignore_readdir_race -type f \
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
					mkdir -p "$GLUE_WD/.glue/$fileDir/auto/${file%/*}"
					cp "$GLUE_STORE/$fileDir/$file" "$GLUE_WD/.glue/$fileDir/auto/${file%/*}"
					;;
				*)
					cp "$GLUE_STORE/$fileDir/$file" "$GLUE_WD/.glue/$fileDir/auto/"
				esac
			else
				log.warn "Corresponding file for annotation'$annotationName()' not found in directory '$GLUE_STORE/$fileDir'. Skipping'"
			fi
		done
	done
}

doCmd() {
	[[ -z $1 ]] && die 'No meta task passed'

	# -------------- Store Init (*.boostrap.sh) -------------- #
	local commandsBootstrapFile actionsBootstrapFile

	helper.get_executable_file "$GLUE_STORE/commands.bootstrap"
	commandsBootstrapFile="$REPLY"
	GLUE_COMMANDS_BOOTSTRAP="$(
		cat "$commandsBootstrapFile"
	)" || die "Could not get contents of '$commandsBootstrapFile' successfully"

	helper.get_executable_file "$GLUE_STORE/actions.bootstrap"
	actionsBootstrapFile="$REPLY"
	GLUE_ACTIONS_BOOTSTRAP="$(
		cat "$actionsBootstrapFile"
	)" || die "Could not get contents of '$actionsBootstrapFile' successfully"

	# *this* task is the specific task like 'build', 'ci', etc., even though
	# we still call "$1" a 'task'
	get.task "$1"
	local task="$REPLY"

	get.projectType "$1"
	local projectType="$REPLY"

	local commandDir="$GLUE_WD/.glue/commands"
	if [[ -z $projectType ]]; then
		# no specific language on cli. run all specified languages as per glue.sh
		[[ ! -v GLUE_USING ]] && {
			die "Please set 'using' in the Glue project configuration (glue.sh)"
			return
		}

		helper.run_task_scripts "$task" "$commandDir" "${GLUE_USING[@]}"
	else
		# run only the command specific to a language
		helper.run_task_and_projectType_scripts "$task" "$commandDir" "$projectType"
	fi
}
