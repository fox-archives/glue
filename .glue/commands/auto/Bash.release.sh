#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

#
# glue useAction(util-release-pre.sh)
util.get_action 'util-release-pre.sh'
source "$REPLY" 'notDry'
newVersion="$REPLY"

# Bash version bump
sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1${newVersion}\2|g" ./**/*.{sh,bash} || :

# glue useAction(util-release-post.sh)
util.get_action 'util-release-post.sh'
source "$REPLY" 'notDry' "$newVersion"

# glue useAction(result-pacman-package.sh)
util.get_action 'result-pacman-package.sh'
source "$REPLY"

unset newVersion
unbootstrap
