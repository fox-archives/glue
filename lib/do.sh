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
	helper.get_executable_file "$GLUE_STORE/commands.bootstrap"
	local commandsBootstrapFile="$REPLY"
	GLUE_COMMANDS_BOOTSTRAP="$(
		cat "$commandsBootstrapFile"
	)" || die "Could not get contents of '$commandsBootstrapFile'"

	helper.get_executable_file "$GLUE_STORE/actions.bootstrap"
	local actionsBootstrapFile="$REPLY"
	GLUE_ACTIONS_BOOTSTRAP="$(
		cat "$actionsBootstrapFile"
	)" || die "Could not get contents of '$actionsBootstrapFile'"

	get.task "$1"
	local task="$REPLY"

	get.projectType "$1"
	local projectType="$REPLY"

	get.when "$1"
	local when="$REPLY"

	if [[ -v DEBUG ]]; then
		echo "task: $task"
		echo "projectType: $projectType"
		echo "when: $when"
	fi

	if [ -z "$task" ]; then
		die "Specifying a 'task is required"
	fi

	local commandDir="$GLUE_WD/.glue/commands"
	local hasRan=no

	# specify projectTypes
	local -a projectTypes=()
	if [ -n "$projectType" ]; then
		projectTypes=("$projectType" "")
	else
		[[ ! -v GLUE_USING ]] && {
			die "Must set the 'using' variable in the Glue project configuration (glue.sh)"
			return
		}
		projectTypes=("${GLUE_USING[@]}" "")
	fi

	# specify whens
	local -a whens=()
	if [ -n "$when" ]; then
		# a blank 'when' represents a file like 'build-go.sh' compared to 'build-go-before.sh'
		case "$when" in
			before) whens=("-before") ;;
			only) whens=("") ;;
			after) whens=("-after") ;;
			*) die "When '$when' not valid. Must be of either 'before', 'only', or 'after'"
		esac
	else
		whens=("-before" "" "-after")
	fi

	for projectType in "${projectTypes[@]}"; do
		for when in "${whens[@]}"; do
			helper.get_executable_file "$commandDir/${projectType}.${task}${when}"
			local overrideFile="$REPLY"

			helper.get_executable_file "$commandDir/auto/${projectType}.${task}${when}"
			local autoFile="$REPLY"

			if [ -f "$overrideFile" ]; then
				helper.exec_file "$overrideFile" "no"
				hasRan=yes
			elif [ -f "$autoFile" ]; then
				helper.exec_file "$autoFile" "yes"
				hasRan=yes
			fi
		done

	done

	if [[ $hasRan == no ]]; then
		printf -v msg "%s\n    -> %s\n    -> %s\nExiting" "Task '$task' did not match any files in the following directories" ".glue/commands/auto" ".glue/commands"
		log.error "$msg"
	fi
}
