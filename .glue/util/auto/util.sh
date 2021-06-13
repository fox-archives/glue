# shellcheck shell=bash

# @name util.sh
# @brief Common miscellaneous functions

# Get the absolute path of the absolute working directory of
# the current project. Do not specify function with '()' because
# we assume consumer invokes function in subshell to capture output
util.get_working_dir() {
	while [ ! -f "glue.sh" ] && [ "$PWD" != / ]; do
		cd ..
	done

	if [ "$PWD" = / ]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s\n" "$PWD"
}

# Get any particular file, parameterized by any
# top level folder contained within "$GLUE_WD/.glue"
util.get_file() {
	local dir="$1"
	local file="$2"

	ensure.nonZero 'dir' "$dir"
	ensure.nonZero 'file' "$file"

	REPLY=
	if [ -f "$GLUE_WD/.glue/$dir/$file" ]; then
		REPLY="$GLUE_WD/.glue/$dir/$file"
	elif [ -f "$GLUE_WD/.glue/$dir/auto/$file" ]; then
		REPLY="$GLUE_WD/.glue/$dir/auto/$file"
	else
		error.file_not_found_in_dot_glue_dir "$file" "$dir"
	fi
}

# Get any particular file in the 'actions' directory
# Pass '-q' as the first arg to set the result to
# '$REPLY' rather than outputing to standard output
util.get_action() {
	if [ "$1" = "-p" ]; then
		util.get_file "actions" "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file "actions" "$1"
	fi
}

# Get any particular file in the 'tasks' directory
# Pass '-q' as the first arg to set the result to
# '$REPLY' rather than outputing to standard output
util.get_task() {
	if [ "$1" = "-p" ]; then
		util.get_file "tasks" "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file "tasks" "$1"
	fi
}

# Get any particular file in the 'configs' directory
# Pass '-q' as the first arg to set the result to
# '$REPLY' rather than outputing to standard output
util.get_config() {
	if [ "$1" = "-p" ]; then
		util.get_file "configs" "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file "configs" "$1"
	fi
}

util.ln_config() {
	ensure.args 'util.ln_config' '1 2' "$@"

	if [ -f "$GLUE_WD/.glue/configs/$1" ]; then
		ln -sfT ".glue/configs/$1" "${2:-"$GLUE_WD/$1"}"
	elif [ -f "$GLUE_WD/.glue/configs/auto/$1" ]; then
		ln -sfT ".glue/configs/auto/$1" "${2:-"$GLUE_WD/$1"}"
	else
		error.file_not_found_in_dot_glue_dir "$1" 'configs'
	fi
}

# Set or unset a shopt parameter, which will be reversed
# during the bootstrap.deinit phase
util.shopt() {
	ensure.args 'util.shopt' '1 2' "$@"

	shopt "$1" "$2"
	_util_shopt_data+="$1.$2 "
}

util.prompt_new_version_string() {
	REPLY=

	local newVersion=
	if is.wet_release; then
		toml.get_key 'version' 'glue-auto.toml'
		currentVersion="$REPLY"

		# TODO: make incremenet better
		echo "Current Version: $currentVersion"
		read -rp 'New Version? ' -ei "$currentVersion"

		newVersion="$REPLY"

		ensure.nonZero 'newVersion' "$newVersion"
		ensure.version_is_only_major_minor_patch "$newVersion"
		ensure.git_version_tag_validity "$newVersion"
	else
		# When in 'dry' mode, the 'new version' is just the current version
		toml.get_key 'version' 'glue-auto.toml'
		newVersion="$REPLY"

		ensure.nonZero 'newVersion' "$newVersion"

		# The extra checks for major_minor_patch (and Git tag validity) aren't
		# checked since we expect to see the commit (and potentially '-DIRTY')
		# in the version. If a particular tool doesn't allow adding '-' or '+'
		# to the version, we handle it on the spot, in that particular context
	fi

	REPLY="$newVersion"
}

# @description Writes the new version string to 'glue-auto.toml'
# and any relevant source files
util.update_version_strings() {
	local version="$1"

	ensure.nonZero 'version' "$version"

	ensure.file 'glue-auto.toml'

	# Write version
	if grep -q 'version' glue-auto.toml; then
		sed -i -e "s|\(version[ \t]*=[ \t]*[\"']\).*\([\"']\)|\1${version}\2|g" glue-auto.toml
	else
		echo "version = '$version'" >| glue-auto.toml
	fi

	# Write version (project type specific)
	if command -v custom.bump_version_hook &>/dev/null; then
		if ! custom.bump_version_hook "$version"; then
			die "Hook 'custom.bump_version_hook' did not complete successfully"
		fi
	fi
	unset custom.bump_version_hook
}

util.extract_version_string() {
	REPLY=

	ensure.git_repository_initialized

	# If the working tree is dirty and there are unstaged changes
	# for both tracked and untracked files
	local dirty=
	if is.git_working_tree_dirty; then
		dirty=yes
	fi

	# Get the most recent Git tag that specifies a version
	local version
	if version="$(git describe --match 'v*' --abbrev=0 2>/dev/null)"; then
		version="${version/#v/}"
	else
		version="0.0.0"
	fi

	local id
	id="$(git rev-parse --short HEAD)"
	version+="+$id${dirty:+-DIRTY}"
	REPLY="$version"
}
