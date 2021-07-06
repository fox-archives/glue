# shellcheck shell=bash

# TODO: pass option whether to explicitly use 'auto' or non-auto file
do-run-action() {
	local actionFile="${argsCommands[1]}"
	[[ -z $actionFile ]] && die 'No action file passed'

	# -------------- Store Init (*.boostrap.sh) -------------- #
	helper.get_executable_file "$GLUE_STORE/bootstrap"
	local bootstrapFile="$REPLY"
	GLUE_BOOTSTRAP=$(<"$bootstrapFile") || die "Could not get contents of bootstrap file '$bootstrapFile'"

	# Grab files to execute
	helper.get_executable_file "$GLUE_WD/.glue/actions/$actionFile"
	local overrideFile="$REPLY"

	helper.get_executable_file "$GLUE_WD/.glue/actions/auto/$actionFile"
	local autoFile="$REPLY"

	hasRan=no
	if [ -f "$overrideFile" ]; then
		helper.exec_file "$overrideFile" "no"
		hasRan=yes
	elif [ -f "$autoFile" ]; then
		helper.exec_file "$autoFile" "yes"
		hasRan=yes
	fi

	if [[ $hasRan == no ]]; then
		log.error "Action file '$actionFile' did match any files"
		echo "    -> Is the action contained in '.glue/actions/auto' or '.glue/actions'?" >&2
		echo "    -> Did you specify the action without the file extension?" >&2
		exit 1
	fi
}
