#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

action() {
	local version="$1"
	local changelogFile="$2"
	local targetBranch="${3:-main}"

	ensure.nonZero 'version' "$version"
	ensure.nonZero 'changelogFile' "$changelogFile"
	ensure.nonZero 'targetBranch' "$targetBranch"

	ensure.file "$changelogFile"

	if is.wet_release; then
		gh release create "v$version" --target "$targetBranch" --title "v$version" '-F' "$changelogFile"
	else
		log.info "Skipping GitHub artifact upload"
	fi
}


action "$@"
unbootstrap
