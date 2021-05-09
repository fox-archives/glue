# shellcheck shell=sh

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
	ensure_fn_args 'ensure_not_empty' '1 2' "$@"

	if [ -z "$2" ]; then
		die "Variable '$1' is blank"
	fi
}

ensure_file_exists() {
	ensure_fn_args 'ensure_file_exists' '1' "$@"

	if [ ! -f "$1" ]; then
		die "File '$1' does not exist"
	fi
}

ensure_fn_args() {
	fnName="$1"
	args="$2"
	shift; shift

	for arg in $args; do
		argValue="$(eval "echo '\${$arg}'")"
		if [ -z "$argValue" ]; then
			die "ensure_fn_args: Arg '$arg' cannot be empty for '$fnName'"
			return 1
		fi
	done
}

ensure_no_dash() {
	ensure_fn_args 'ensure_no_dash' '1' "$@"
}
