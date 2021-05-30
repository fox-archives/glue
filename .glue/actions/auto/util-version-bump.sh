#!/usr/bin/env bash

unset main
main() {
	local newVersion="$1"

	sed -i -e "s|\(version[ \t]*=[ \t]*\"\).*\(\"\)|\1${newVersion}\2|g" glue-auto.toml
}

main "$@"
unset main
