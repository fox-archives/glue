# shellcheck shell=bash

# @name log.sh
# @brief Only contains simple logging functions

# @description Print info
log.info() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Info: $*"
	else
		printf "\033[0;34m%s\033[0m\n" "Info: $*"
	fi
}

# @description Print warning
log.warn() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Warn: $*"
	else
		printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
	fi
}

# @description Print error
log.error() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Error: $*"
	else
		printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
	fi
}
