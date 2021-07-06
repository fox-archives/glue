# shellcheck shell=bash

do-run-task() {
	local metaTask="${argsCommands[1]}"
	[[ -z $metaTask ]] && die 'No meta task passed'

	# -------------- Store Init (*.boostrap.sh) -------------- #
	helper.get_executable_file "$GLUE_STORE/bootstrap"
	local bootstrapFile="$REPLY"
	GLUE_BOOTSTRAP=$(<"$bootstrapFile") || die "Could not get contents of bootstrap file '$bootstrapFile'"

	# -------------------- Parse Meta task ------------------- #
	get.task "$metaTask"
	local task="$REPLY"

	get.projectType "$metaTask"
	local projectType="$REPLY"

	get.when "$metaTask"
	local when="$REPLY"

	# --------------------- Sanity check --------------------- #
	if [ -z "$task" ]; then
		die "Specifying a 'task is required"
	fi

	if [[ -v DEBUG_GLUE ]]; then
		echo "task: $task"
		echo "projectType: $projectType"
		echo "when: $when"
	fi

	# calculate 'projectType's to run
	local -a projectTypes=()
	if [[ -v GLUE_USING ]]; then
		projectTypes=("" "${GLUE_USING[@]}")
	else
		die "Must set the 'using' variable in the Glue project configuration (glue.toml)"
	fi

	# calculate 'when's to run
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

	# run and execute files in order
	local hasRan=no
	for projectType in "${projectTypes[@]}"; do
		for when in "${whens[@]}"; do
			helper.get_executable_file "$GLUE_WD/.glue/tasks/${projectType}.${task}${when}"
			local overrideFile="$REPLY"

			helper.get_executable_file "$GLUE_WD/.glue/tasks/auto/${projectType}.${task}${when}"
			local autoFile="$REPLY"

			if [ -f "$overrideFile" ]; then
				helper.exec_file "$overrideFile" "no" "${argsPostHyphen[@]}"
				hasRan=yes
			elif [ -f "$autoFile" ]; then
				helper.exec_file "$autoFile" "yes" "${argsPostHyphen[@]}"
				hasRan=yes
			fi
		done

	done

	if [[ $hasRan == no ]]; then
		log.error "Task '$task' did match any files"
		echo "    -> Is the task contained in '.glue/tasks/auto' or '.glue/tasks'?" >&2
		echo "    -> Was a task like 'build', 'ci', etc. actually specified?" >&2
		exit 1
	fi
}
