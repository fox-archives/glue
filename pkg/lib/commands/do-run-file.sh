# shellcheck shell=bash

do-run-file() {
	local file="${argsCommands[1]}"
	[[ -z $file ]] && die 'No file task passed'

	# -------------- Store Init (*.boostrap.sh) -------------- #
	helper.get_executable_file "$GLUE_STORE/bootstrap"
	local bootstrapFile="$REPLY"
	GLUE_BOOTSTRAP=$(<"$bootstrapFile") || die "Could not get contents of bootstrap file '$bootstrapFile'"

	if [ -x "$file" ]; then
		helper.exec_file "$file" "yes"
	elif [ -f "$file" ]; then
		die "File '$file' exists, but it is not marked as executable"
	else
		die "File '$file' does not exist"
	fi
}
