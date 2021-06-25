# shellcheck shell=bash

# @name util.sh
# @brief Common miscellaneous functions

# Get the absolute path of the absolute working directory of
# the current project. Do not specify function with '()' because
# we assume consumer invokes function in subshell to capture output
util.get_working_dir() {
	local fn='util.get_working_dir'
	bootstrap.fn "$fn"

	while [ ! -f "glue.sh" ] && [ "$PWD" != / ]; do
		ensure.cd ..
	done

	if [ "$PWD" = / ]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s\n" "$PWD"

	unbootstrap.fn
}

# Get any particular file, parameterized by any
# top level folder contained within "$GLUE_WD/.glue"
util.get_file() {
	local fn='util.get_file'
	bootstrap.fn "$fn"

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

	unbootstrap.fn
}

# Get any particular file in the 'actions' directory
# Pass '-p' to the first arg to standard output rather
# than setting '$REPLY'
util.get_action() {
	local fn='util.get_action'
	bootstrap.fn "$fn"

	if [ "$1" = "-p" ]; then
		util.get_file 'actions' "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file 'actions' "$1"
	fi

	unbootstrap.fn
}

# Get any particular file in the 'tasks' directory
# Pass '-p' to the first arg to standard output rather
# than setting '$REPLY'
util.get_task() {
	local fn='util.get_task'
	bootstrap.fn "$fn"

	if [ "$1" = "-p" ]; then
		util.get_file 'tasks' "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file 'tasks' "$1"
	fi

	unbootstrap.fn
}

# Get any particular file in the 'configs' directory
# Pass '-p' to the first arg to standard output rather
# than setting '$REPLY'
util.get_config() {
	local fn='util.get_config'
	bootstrap.fn "$fn"

	if [ "$1" = "-p" ]; then
		util.get_file 'config' "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file 'configs' "$1"
	fi

	unbootstrap.fn
}

util.ln_config() {
	local fn='util.ln_config'
	bootstrap.fn "$fn"

	ensure.args 'util.ln_config' '1 2' "$@"

	if [ -f "$GLUE_WD/.glue/configs/$1" ]; then
		ln -sfT ".glue/configs/$1" "${2:-"$GLUE_WD/$1"}"
	elif [ -f "$GLUE_WD/.glue/configs/auto/$1" ]; then
		ln -sfT ".glue/configs/auto/$1" "${2:-"$GLUE_WD/$1"}"
	else
		error.file_not_found_in_dot_glue_dir "$1" 'configs'
	fi

	unbootstrap.fn
}

# Set or unset a shopt parameter, which will be reversed
# during the bootstrap.deinit phase
util.shopt() {
	local fn='util.shopt'
	bootstrap.fn "$fn"

	ensure.args 'util.shopt' '1 2' "$@"

	shopt "$1" "$2"
	_util_shopt_data+="$1.$2 "

	unbootstrap.fn
}

util.prompt_new_version_string() {
	local fn='util.prompt_new_version_string'
	bootstrap.fn "$fn"

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

	unbootstrap.fn
}

# @description Writes the new version string to 'glue-auto.toml'
# and any relevant source files
# @noargs
util.update_version_strings() {
	local fn='util.update_version_strings'
	bootstrap.fn "$fn"

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
	util.run_hook 'hook.util.update_version_strings.bump_version'

	unbootstrap.fn
}

# @description Extracts the most recent version string. This version
# string complies with Semantic Versioning, and may include the
# current short commit hash, and a qualifier specifying the state of the Git
# working tree ('-DIRTY' or '')
# @noargs
util.extract_version_string() {
	local fn='util.extract_version_string'
	bootstrap.fn "$fn"

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

	unbootstrap.fn
}

# @description Runs a particular hook, then unsets the hook name
# @arg $1 string Name of the hook
util.run_hook() {
	local fn='util.run_hook'
	bootstrap.fn "$fn"

	local hookName="$1"

	ensure.nonZero 'hookName' "$hookName"

	if command -v "$hookName"; then
			if ! "$hookName"; then
				die "Hook '$hookName' did not complete successfully"
			fi
		fi
		unset "$hookName"

	unbootstrap.fn
}

# @description Prints the current callstack
# @noarg
util.callstack_print() {
	local ff=
	local -a callSites

	echo 'CALLSTACK'
	while IFS=\; read -ra callSites; do
		for callSite in "${callSites[@]}"; do
			printf "%s\n" "$ff=> $callSite"

			ff+="  "
		done
	done <<< "$GLOBAL_CALLSTACK"
}
