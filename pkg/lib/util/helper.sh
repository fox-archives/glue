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

# TODO: have command that pulls automatically
# @description Switch to the correct Glue version
# @noargs
helper.switch_to_correct_glue_version() {
	if [[ -v GLUE_NO_SWITCH_VERSION ]]; then
		log.warn "Environment variable 'GLUE_NO_SWITCH_VERSION' is set. Skipping version switch"
		return
	fi

	local glueDataDir="${XDG_DATA_HOME:-$HOME/.local/share}/glue"

	# Ensure we have a repository with the full history
	if [ ! -d "$glueDataDir/repository" ]; then
		if ! git clone 'https://github.com/eankeen/glue' "$glueDataDir/repository" &>/dev/null; then
			die "Could not clone Glue to '$glueDataDir/repository'"
		fi
	fi
	if ! git -C "$glueDataDir/repository" pull &>/dev/null; then
		die "Could not pull latest Glue changes. Delete '$glueDataDir/repository' and try again"
	fi

	if ! util.get_toml_string "$GLUE_WD/glue-auto.toml" 'glueVersion'; then
		die "You must have a 'glueVersion' key in 'glue-auto.toml'"
	fi
	# newVersion is the version of Glue that we want to change to
	local newVersion="$REPLY"

	if [ -z "$newVersion" ]; then
		die "There must be a value for 'glueVersion' in 'glue-auto.toml'"
	fi

	echo debug "$PROGRAM_LIB_DIR"
	# For now, assume that 'Glue' was installed with Git
	local currentVersionSha1= currentVersionTag=
	if ! currentVersionSha1="$(git -C "$PROGRAM_LIB_DIR/../../" rev-parse HEAD)"; then
		die "Could not grab the SHA1 of the current Glue version"
	fi
	if ! currentVersionTag="$(git -C "$PROGRAM_LIB_DIR/../../" describe --exact-match --tags HEAD 2>/dev/null)"; then
		# Not all revisions will have a Git tag, which is why some errors are OK. This doesn't
		# match all fatal errors, but we are ignoring that for now, since 'newVersion' won't match with the
		# error or an empty string
		:
	fi

	if [[ -v GLUE_DEBUG ]]; then
		cat <<-EOF
		newVersion: $newVersion
		currentVersionSha1: $currentVersionSha1
		currentVersionTag: $currentVersionTag
		EOF
	fi

	# If the current version is the same as the one specified in `glue-auto.toml`, then
	# return as there is no need to switch versions
	if [[ "$newVersion" = "$currentVersionSha1" || "$newVersion" = "$currentVersionTag" ]]; then
		log.info "Using current ($newVersion) Glue version"
		return
	fi

	# Note that we are not converting SHA1 revisions to their respective tags, if they
	# have any. This is to make things simpler
	if [ ! -d "$glueDataDir/versions/$newVersion" ]; then
		mkdir -p "$glueDataDir/versions/$newVersion"
		if ! git -C "$glueDataDir/versions/$newVersion" clone 'https://github.com/eankeen/glue' . &>/dev/null; then
			die "Could not clone Glue version '$newVersion' to '$glueDataDir/versions'"
		fi

		if ! git -C "$glueDataDir/versions/$newVersion" reset --hard "$newVersion"; then
			die "Could not reset the version of Glue to '$newVersion' in '$glueDataDir/versions/$newVersion'"
		fi
	fi

	if [ "$(git -C "$glueDataDir/versions/$newVersion" rev-parse HEAD)" != "$newVersion" ]; then
		die "Verification of revision switch for directory '$glueDataDir/versions/$newVersion' failed"
	fi

	log.info "Using new ($newVersion) Glue version"
	exec "$glueDataDir/versions/$newVersion/pkg/bin/glue" "$@"
}
