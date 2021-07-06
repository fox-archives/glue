# shellcheck shell=bash

# @description Ensures a particular argument is not empty,
# terminating the program if it is empty
# @arg $1 string Name of the variable
# @arg $2 string Value of the variable
ensure.nonZero() {
	local varName="$1"
	local varValue="$2"

	if [ -z "$varName" ] || [ $# -ne 2 ]; then
		die "ensure.nonZero: Incorrect arguments passed to 'ensure.nonZero'"
	fi

	if [ -z "$varValue" ]; then
		die "ensure.nonZero: Variable '$varName' must be non-zero"
	fi
}

# @description Ensures that a file exists. If it does not,
# the program is terminated
# @arg $1 string Path of the file to check. Recommend passing an absolute path
ensure.file() {
	local fileName="$1"

	ensure.nonZero 'fileName' "$fileName"

	if [ ! -f "$fileName" ]; then
		die "ensure.file: File '$fileName' does not exist. It must exist"
	fi
}
