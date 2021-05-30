#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(util-release-pre.sh)
util.get_action 'util-release-pre.sh'
source "$REPLY" 'dry'
newVersion="$REPLY"

# Bash version bump
(
	shopt -s dotglob
	shopt -s nullglob
	shopt -s globstar

	find . -ignore_readdir_race -regex '\./pkg/.*\.\(sh\|bash\)' -print0 2>/dev/null \
		| xargs -r0 \
		sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1${newVersion}\2|g"
) || exit

unbootstrap
