#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

task() {
	# glue useAction(tool-shdoc.sh)
	util.get_action 'tool-shdoc.sh'
	source "$REPLY"
	local exitOne="$REPLY"

	hook.tool-mkdocs.copy_docs() {
		mkdir -p docs/shdoc
		cp -r "$GLUE_WD/.glue/generated/tool-shdoc" ./docs/shdoc
	}
	# glue useAction(tool-mkdocs.sh)
	util.get_action 'tool-mkdocs.sh'
	source "$REPLY"
	local exitTwo="$REPLY"

	REPLY="$((exitOne | exitTwo))"
}

task "$@"
unbootstrap
