# shellcheck shell=bash

# -------------------------- run ------------------------- #

trap sigint INT
sigint() {
	set +x
	die 'Received SIGINT'
}


# -------------------- util functions -------------------- #

die() {
	log_error "${*-'die: '}. Exiting"
	exit 1
}

log_info() {
	printf "\033[0;34m%s\033[0m\n" "Info: $*"
}

log_warn() {
	printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
}

log_error() {
	printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
}

ensure_not_empty() {
	ensure_fn_args 'ensure_not_empty' '1' "$@" || return

	if [ -z "$2" ]; then
		die "Variable '$1' is empty"
	fi
}

ensure_file_exists() {
	ensure_fn_args 'ensure_file_exists' '1' "$@" || return

	if [ ! -f "$1" ]; then
		die "File '$1' does not exist"
	fi
}

# execs a file if it exists, but prints a warning if
# the file is there, but not executable
exec_file() {
	ensure_fn_args 'exec_file' '1 2' "$@" || return
	file="$1"
	isAuto="$2"

	if [[ ${file::1} != / && ${file::2} != ./ ]]; then
		file="./$file"
	fi

	if [ -f "$file" ]; then
		if [ -x "$file" ]; then
			# shellcheck disable=SC2097
			GLUE_ACTIONS_DIR="$GLUE_ACTIONS_DIR" \
					GLUE_COMMANDS_DIR="$GLUE_COMMANDS_DIR" \
					GLUE_CONFIGS_DIR="$GLUE_CONFIGS_DIR" \
					GLUE_COMMANDS_BOOTSTRAP="$GLUE_COMMANDS_BOOTSTRAP" \
					GLUE_ACTIONS_BOOTSTRAP="$GLUE_ACTIONS_BOOTSTRAP" \
					GLUE_IS_AUTO="$isAuto" \
					"$file"
			return
		else
			die "File '$file' exists, but is not executable. Bailing early to prevent out of order execution"
		fi
	else
		log_error "Could not exec file '$file' because it does not exist"
	fi
}

ensure_fn_args() {
	fnName="$1"
	args="$2"
	shift; shift

	for arg in $args; do
		argValue="$(eval "echo \"\${$arg}\"")"
		if [ -z "$(<<< "$argValue" awk '{ $1=$1; print }')" ]; then
			die "ensure_fn_args: Arg '$arg' cannot be empty for '$fnName'"
			return 1
		fi
	done
}

contains_element() {
	local match="$1"
	shift

	local item
	for item; do [[ "$item" == "$match" ]] && return 0; done
	return 1
}

show_help() {
	# TODO better help
	cat <<-EOF
	Commands:
	glue

	    sync
	        Sync changes to current project

	    cmd <task>
	        Perform task
	EOF
}
