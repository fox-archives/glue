# shellcheck shell=bash

# @description Checks to see if a valid executable exists at a location.
# For example, when passed in 'some-file', it may return 'some-file.py'
# or 'some-file.sh', depending on what is in the directory
# @arg $1 Name of potential executable file, without the file extension
helper.get_executable_file() {
	local file="$1"
	REPLY=

	if [[ -v DEBUG_GLUE ]] && { :>&3; } 2>/dev/null; then
		echo "Debug: helper.get_executable_file: $file" >&3
	fi

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

	if [[ -n $firstFileMatch && ! -x $firstFileMatch ]]; then
		log.warn "File '$firstFileMatch' will be executed, but it is not marked as executable"
	fi

	REPLY="$firstFileMatch"
}

# @description execs a file if it exists, but prints a warning if
# the file is there, but not executable
# @arg $1 File to execute
# @arg $2 Value to set $GLUE_IS_AUTO when executing file
helper.exec_file() {
	file="$1"
	isAuto="$2"
	shift; shift

	if [[ ${file::1} != / && ${file::2} != ./ ]]; then
		file="./$file"
	fi

	if [ -f "$file" ]; then
		if [ -x "$file" ]; then
			if [ "${args[dry]}" = yes ]; then
				log.info "Would have executed '$file'"
			else
				GLUE_WD="$GLUE_WD" \
					GLUE_IS_AUTO="$isAuto" \
					GLUE_BOOTSTRAP="$GLUE_BOOTSTRAP" \
					"$file" "$@"
			fi

			return
		else
			die "File '$file' exists, but is not executable. Bailing early to prevent out of order execution"
		fi
	else
		log.error "Could not exec file '$file' because it does not exist"
	fi
}

# @description Switch to the correct Glue version
# @noargs
helper.switch_to_correct_glue_version() {
	if [[ -v GLUE_NO_SWITCH_VERSION ]]; then
		return
	fi

	util.get_toml_string "$GLUE_WD/glue-auto.toml" 'glueVersion'
	local glueVersion="$REPLY"

	# shellcheck disable=SC1007
	local actualGlueVersionGit= actualGlueVersion=
	if [ -d "$PROGRAM_LIB_DIR/../../.git" ]; then
		cd "$PROGRAM_LIB_DIR/../../.git"
		# TODO: Information about current Git repository should be autogenerated
		actualGlueVersionGit="$(git -C "$PROGRAM_LIB_DIR/../../" rev-parse HEAD)"
		cd "$GLUE_WD"
	fi
	actualGlueVersion="${PROGRAM_VERSION%*:}"
	actualGlueVersion="${actualGlueVersion%"${actualGlueVersion##*[![:space:]]}"}"

	if [[ -v GLUE_DEBUG ]]; then
		cat <<-EOF
		glueVersion: $glueVersion
		actualGlueVersion: $actualGlueVersion
		actualGlueVersionGit: $actualGlueVersionGit
		EOF
	fi

	if [[ -n "$actualGlueVersionGit" && "$glueVersion" != "$actualGlueVersionGit" ]] \
			&& [ "$glueVersion" != "$actualGlueVersion" ]
		then
			# TODO: this strategy would have to improve if we want to run multiple different versions of Glue concurrently
			log.info 'Executing Glue from the managed repository'
			local versionDir="${XDG_DATA_HOME:-$HOME/.local/share}/glue/repository"
			if [ ! -d "$versionDir" ]; then
				mkdir -p "$versionDir"
				git -C "$versionDir" clone 'https://github.com/eankeen/glue' .
			fi

			if ! git -C "$versionDir" cat-file -e "$glueVersion" 2>/dev/null; then
				echo
				git -C "$versionDir" fetch origin main
				git -C "$versionDir" merge origin main
			fi

			if ! git -C "$versionDir" cat-file -e "$glueVersion" 2>/dev/null; then
				die "glueVersion '$glueVersion' is not a valid Git object for the 'Glue' repository"
			fi

			git -C "$versionDir" switch "$glueVersion" >/dev/null 2>&1
			"$versionDir/pkg/bin/glue" "$@"
	fi
}
