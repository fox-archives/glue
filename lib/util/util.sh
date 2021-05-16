# shellcheck shell=bash

util.source_error() {
	echo "Error: Could not source file"
	exit 1
}

# Strips the prefix from an absolute path
util.strip_absolute_path() {
	prefix="$1"
	path="$2"

	prefixLength="${#1}"

	if [[ $prefix = "${path::$prefixLength}" ]]; then
		REPLY="${path:$prefixLength:}"
	fi
}

util.show_help() {
	cat <<-EOF
	glue [flags] <command>

	Commands:
	    sync
	        Sync changes from the Glue store to the current project.
	        This overrides and replaces the content in 'auto' directories

	    cmd <metaTask>
	        Perform a meta task. See \`docs/details.md\` for more information

	Flags:
	    --help
	        Show help menu

	    --version
	        Show current version
	EOF
}

util.show_version() {
	# TODO
	cat <<-EOF
	VERSION
	EOF
}
