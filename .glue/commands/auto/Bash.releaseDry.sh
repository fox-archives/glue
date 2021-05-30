#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# TODO: merge with Bash.release and add --dry

# shellcheck disable=SC2034
readonly RELEASE_STATUS='dry'

util.get_command 'Bash.build.sh'
source "$REPLY"

# glue useAction(util-release-pre.sh)
util.get_action 'util-release-pre.sh'
source "$REPLY"

# glue useAction(util-get-version.sh)
util.get_action 'util-get-version.sh'
source "$REPLY"
declare newVersion="$REPLY"

# glue useAction(util-Bash-version-bump.sh)
util.get_action 'util-Bash-version-bump.sh'
source "$REPLY" "$newVersion"

# glue useAction(util-release-post.sh)
util.get_action 'util-release-post.sh'
source "$REPLY" 'dry' "$newVersion"

# glue useAction(result-pacman-package.sh)
util.get_action 'result-pacman-package.sh'
source "$REPLY"

unset newVersion

unbootstrap
