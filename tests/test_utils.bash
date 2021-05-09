# shellcheck shell=bash

test_util_print_args() {
	for arg; do
		printf "%s" "$arg"
	done
}
