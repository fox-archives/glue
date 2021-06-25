# shellcheck shell=bash
# @file util.sh
# @brief Utility functions
# @description Contains utility functions for the library


# @description Prints 'Could not source file' error and exits
#
# @example
#   source ./non-existent-file || util.source_error
#
# @exitcode 1 Exits with `1`
util.source_error() {
	echo "Error: Could not source file"
	exit 1
}

# @description Prints the help menu
util.show_help() {
	cat <<-EOF
	glue [flags] <command>

	Commands:
	    sync
	        Sync changes from the Glue store to the current project.
	        This overrides and replaces the content in 'auto' directories

	    list
	        Lists all projectTypes of the current project

	    print
	        Prints the script about to be executed

	    act <actionFile>
	        Execute an action

	    cmd <metaTask>
	        Execute a meta task (command)

	Flags:
	    --help
	        Show help menu

	    --version
	        Show current version
	EOF
}

# @description Prints the current version
util.show_version() {
	cat <<-EOF
	Version: $PROGRAM_VERSION
	EOF
}
