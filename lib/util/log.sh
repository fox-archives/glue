# shellcheck shell=bash

die() {
	if [[ -n $* ]]; then
		log.error "$*. Exiting"
	else
		log.error "Exiting"
	fi

	exit 1
}

log.info() {
	printf "\033[0;34m%s\033[0m\n" "Info: $*"
}

log.warn() {
	printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
}

log.error() {
	printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
}
