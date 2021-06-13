#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

action() {
	local version="$1"

	ensure.nonZero 'version' "$version"

	if is.wet_release; then
		git add -A
		git commit -m "chore(release): v$version"
		git tag -a "v$version" -m "Release $version" HEAD
		git push --follow-tags origin HEAD
	else
		log.info "Skipping Git tag generation"
	fi
}

action "$@"
unbootstrap
