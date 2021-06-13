#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'conventional-changelog'

action() {
	REPLY=

	local version="$1"

	ensure.cmd 'conventional-changelog'
	ensure.file 'glue.toml'
	ensure.nonZero 'version' "$version"

	# glue useConfig(tool-conventional-changelog)
	util.get_config 'tool-conventional-changelog/context.json'
	local configContextJson="$REPLY"

	toml.get_key 'gitRepoName' 'glue.toml'
	local gitRepoName="$REPLY"
	ensure.nonZero 'gitRepoName' "$gitRepoName"

	generated.in 'tool-conventional-changelog'; (
		cd "$GENERATED_DIR" || error.cd_failed

		cp "$configContextJson" .
		sed -i \
			-e "s/TEMPLATE_CONTEXT_VERSION/$version/g" \
			-e "s/TEMPLATE_CONTEXT_REPOSITORY/$gitRepoName/g" \
			'context.json'

		# TODO: want versions to look like # [v0.4.0] ...
		# TODO: make local
		conventional-changelog \
			--outfile "$GLUE_WD/CHANGELOG.md" \
			--preset angular \
			--release-count 0 \
			--context "context.json" \
			--commit-path "$GLUE_WD"


		conventional-changelog \
			--outfile "CHANGELOG-CURRENT.md" \
			--preset angular \
			--release-count 1 \
			--context "context.json" \
			--commit-path "$GLUE_WD"
	); generated.out

	REPLY="$GENERATED_DIR/CHANGELOG-CURRENT.md"
}

action "$@"
unbootstrap
