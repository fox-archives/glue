# shellcheck shell=bash

# @name error.sh
# @brief Contrains logging functions that fall into the class of 'print error and terminate program'

# @description Print error, then exit failure code '1' immediately
# @exitcode 1
die() {
	log.error "${*-"log.die: Terminate application"}. Exiting"
	exit 1
}

# @description If a file was not found in the glue store, print an
# error, showing the directories searched, and any
# common troubleshooting tips
error.file_not_found_in_dot_glue_dir() {
	local file="$1"
	local directory="$2"

	ensure.nonZero 'file' "$file"
	ensure.nonZero 'directory' "$directory"

	log.error "Could not find '$file' in '.glue/$directory' or '.glue/auto/$directory'"
	echo "    -> Did you spell the filename or dirname correctly when using annotations like 'useAction(...)'?"
	echo "    -> Did you spell the filename or dirname correctly when using functions like 'util.get_config' or 'util.ln_config'?"
	exit 1
}

# @description Kills program if a 'cd' fails
# @noargs
error.cd_failed() {
	die "A 'cd' failed"
}

# @description Kills program with an 'argument not supported' error
# @noargs
error.not_supported() {
	die "Argument '$1' not supported"
}

# @description Kills program with an 'argument empty' error
# @noargs
error.empty() {
	die "Argument '$1' is empty"
}

# @description Kills program with a 'file not executable' error
# @noargs
error.not_executable() {
	die "File '$1' is not marked as executable"
}

# TOOD: phase out sionce this isn't that descriptive or good
# @description Kills program with a 'project layout is not conforming' error
# Use this if one of your 'actions' requires a particular directory structure to function
#
# @arg $1 string Reason why the project layout is non-conforming
error.non_conforming() {
	local reason="$1"

	ensure.nonZero 'reason' "$reason"

	die "Your project layout is non-conforming: $reason"
}

# @description Kills program with a 'subshell for generated directories' error
# @noargs
error.generated_failed() {
	die "Failure in subshell for a 'generated.{in,out}' folder context"
}
