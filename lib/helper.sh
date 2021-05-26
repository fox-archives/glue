# shellcheck shell=bash

# @description Checks to see if a valid executable exists at a location.
# For example, when passed in 'some-file', it may return 'some-file.py'
# or 'some-file.sh', depending on what is in the directory
#
# @arg $1 Name of potential executable file, without the file extension
helper.get_executable_file() {
	local file="$1"
	REPLY=

	if [[ -v DEBUG ]] && { :>&3; } 2>/dev/null; then
		echo "Debug: helper.get_executable_file: $file" >&3
	fi

	shopt -q nullglob
	local shoptExitStatus="$?"
	shopt -s nullglob

	hasRanFile=no
	firstFileMatch=
	for aFileMatch in "$file".*?; do
		if [[ $hasRanFile = yes ]]; then
			log.warn "Two files match the same pattern"
			echo "    -> '$aFileMatch" >&2
			echo "    -> '$firstFileMatch'" >&2
			break
		fi

		hasRanFile=yes
		firstFileMatch="$aFileMatch"
	done

	(( shoptExitStatus != 0 )) && shopt -u nullglob


	if [[ -n $firstFileMatch && ! -x $firstFileMatch ]]; then
		log.warn "File '$firstFileMatch' will be executed, but it is not marked as executable"
	fi

	REPLY="$firstFileMatch"
}

# @description execs a file if it exists, but prints a warning if
# the file is there, but not executable
#
# @arg $1 File to execute
# @arg $2 Value to set $GLUE_IS_AUTO when executing file
helper.exec_file() {
	file="$1"
	isAuto="$2"

	if [[ ${file::1} != / && ${file::2} != ./ ]]; then
		file="./$file"
	fi

	if [ -f "$file" ]; then
		if [ -x "$file" ]; then
			GLUE_WD="$GLUE_WD" \
				GLUE_IS_AUTO="$isAuto" \
				GLUE_BOOTSTRAP="$GLUE_BOOTSTRAP" \
				"$file"
			return
		else
			die "File '$file' exists, but is not executable. Bailing early to prevent out of order execution"
		fi
	else
		log.error "Could not exec file '$file' because it does not exist"
	fi
}
